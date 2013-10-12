class RegistrationsController < ApplicationController
  before_filter :check_admin, :only => [:index, :destroy, :submit_waiver, :showwaiver, :find_by_code]
  before_filter :check_login, :only => [:new, :create, :show]
  before_filter :check_is_registered, :only => [:joinsquad]

  before_filter :require_can_register, only: [:new, :create]
  before_filter :require_personal_information, only: [:new, :create]
  before_filter :require_waiver, only: [:new, :create]

  def new
    @registration = Registration.where(person_id: @person, game_id: @current_game).first_or_initialize
    @squads = @current_game.squads.includes(:registrations)

    if @registration.card_code.present?
      return redirect_to registration_path(@registration)
    end
  end

  def submit_waiver
    @reg = Registration.find(params[:id])
    @reg.has_waiver = params[:has]
    @reg.save(:validate => false)

    redirect_to registrations_path
  end

  def create
    @registration = Registration.
      where(person_id: @person, game_id: @current_game).
      first_or_initialize(params[:registration])
    @registration.score = 0
    @registration.squad = nil unless params[:squad_select] == "existing"

    if !@registration.save
      flash[:error] = "Error, could not register you! #{@registration.errors.full_messages.first}"
      return redirect_to new_registration_url
    end

    # Now worry about the squad, because we can't attribute squad leadership without a registration id
    if params[:squad_select] == 'create'
      @squad = Squad.create(
        name: params[:new_squad_name],
        leader_id: @registration.id,
        game_id: @current_game.id,
      )
      if @squad.persisted?
        @registration.update_attribute(:squad, @squad)
      else
        flash[:error] = 'You have been successfully registered, but there was a problem creating your squad: ' + @squad.errors.full_messages.first
      end
    end

    if params[:squad_select] == "existing"
      # Validate that the user has joined an open squad
      if !@registration.squad.can_be_joined?
        @registration.update_attribute(:squad, nil)
        flash[:error] = 'You have been successfully registered, but you could not be joined to the squad because it is full.'
      end
    end

    if @registration.person.phone.present?
      Delayed::Job.enqueue SendNotification.new(@person,
        "Thank you for registering for HvZ. Your card code is: #{@registration.card_code}." +
        'Please keep this code on you at all times. Have fun!')
    end

    redirect_to registration_url(@registration)
  end

  def destroy
    @registration = Registration.find(params[:id])
    @registration.destroy if @registration

    redirect_to registrations_url
  end

  def show
    @registration = Registration.find(params[:id])

    if @registration.person_id != @person.id
      flash[:error] = 'This is not your registration!!'
      return redirect_to root_url
    end
  end

  def update
    r = Registration.find(params[:id])

    if !@is_admin && r.person != @logged_in_person
      flash[:error] = "You do not have permission to edit this registration."
      redirect_to root_url()
    end

    r.attributes = params[:registration]
    r.save(validate: !@is_admin) # if admin, then don't validate.

    redirect_to edit_registration_url(params[:id])
  end

  def edit
    @registration = Registration.find(params[:id])
    @squads = @current_game.squads.sort_by { |x| x.name } #todo: arel this
    @person = @registration.person

    if !@is_admin && @person != @logged_in_person
      flash[:error] = 'You do not have permission to edit this registration.'
      return redirect_to root_url
    end
  end

  def report
    @registration = Registration.find(params[:id])

    if !@is_admin
      flash[:error] = 'You do not have permission to report infractions.'
      return redirect_to root_url
    end
  end

  def index
    @registrations = Registration.where(game_id: @current_game).includes(person: :waivers)
    @registrations.sort_by { |r| r.score } #todo: arel this
  end

  def showwaiver
    @registration = Registration.find(params[:registration_id], include: { person: :waivers })
    @waiver = @registration.person.waivers.where(game_id: @current_game).first
  end

  def find_by_code
    @players = @current_game.registrations.includes(:person)
  end

private

  def require_personal_information
    if @logged_in_person.name.blank?
      return redirect_to edit_person_url(@logged_in_person, next: 'registration')
    end
  end

  def require_waiver
    return unless @logged_in_person.legal_to_sign_waiver?

    current_waiver = Waiver.where(
      person_id: @logged_in_person,
      game_id: @current_game
    ).first

    if current_waiver.blank?
      redirect_to sign_waiver_url(@logged_in_person, next: 'registration')
    end
  end

  # todo[tdooner]: I think this whole method is super jank. Going to revisit at
  # a later time.
  #
  # Does it just assign whoever is logged in to the squad, even if it is an
  # admin signing up another player? Or I guess that's not possible so it's not
  # a problem?
  def joinsquad
    if params[:id].to_i != @logged_in_registration.id.to_i
      flash[:error] = "Error! Trying to sign someone else up into a squad?"
      redirect_to root_url
    elsif @logged_in_registration.squad != nil
      flash[:error] = "Error! You cannot change your squad."
      redirect_to root_url
    elsif !@current_game.has_begun?
      if params[:squadid].eql?("new")
        @squad = Squad.new({
          :name => params[:new_squad_name],
          :leader_id => @logged_in_registration.id,
          :game_id => @current_game.id
        })
        if @squad.save()
          @logged_in_registration.update_attribute(:squad, @squad)
          redirect_to registration_url(@logged_in_registration)
        end
      else
        squad = Squad.find(params[:squadid])
        if squad.can_be_joined?
          @logged_in_registration.update_attribute(:squad, squad)
          redirect_to registration_url(@logged_in_registration)
        else
          flash[:error] = "This squad cannot be joined."
          redirect_to squads_url()
        end
      end
    else
      flash[:error] = "You cannot join a squad after the game has started"
      redirect_to root_url
    end
  end
end
