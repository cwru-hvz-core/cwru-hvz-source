class RegistrationsController < ApplicationController
	before_filter :check_admin, :only => [:index, :destroy, :submit_waiver]
	before_filter :check_login, :only => [:new, :create, :show]
  before_filter :check_is_registered, :only => [:joinsquad]
  before_filter :start_registration_process, :only => [:new]
	def new
		if @current_game.id.nil? or @current_game.registration_begins.nil? or @current_game.registration_ends.nil?
			flash[:error] = "Your administrators have not yet created a game to register for."
			redirect_to root_url()
			return
		end
		if (Time.now + @current_game.utc_offset) < @current_game.registration_begins
			flash[:error] = "Registration begins " + @current_game.dates[:registration_begins] + ". Please check back then!"
			redirect_to root_url()
      return
		end
		if (Time.now + @current_game.utc_offset) > @current_game.registration_ends
			flash[:error] = "Registration ended " + @current_game.dates[:registration_ends] + ". If you would still like to play, please contact the administrators."
			redirect_to root_url()
      return
		end
		@registration = Registration.find_or_initialize_by_person_id_and_game_id(@person.id, @current_game.id)
    @squads = @current_game.squads
		if not @registration.card_code.nil?
      session[:is_registering] = false
			redirect_to registration_url(@registration)
      return
		end
	end
	def submit_waiver
		@reg = Registration.find(params[:id])
		@reg.has_waiver = params[:has]
		@reg.save(false)
		redirect_to registrations_url()
	end
	def create
		@registration = Registration.find_or_initialize_by_person_id_and_game_id(@person.id, @current_game.id)
		@registration.attributes = params[:registration]
		@registration.card_code = Registration.make_code
		@registration.score = 0
    @registration.squad = nil unless params[:squad_select] == "existing"
		if @registration.save()
      session[:is_registering] = false
      
      # Now worry about the squad, because we can't attribute squad leadership without a registration id
      if (params[:squad_select] == "create")
        @squad = Squad.new({
          :name => params[:new_squad_name], 
          :leader_id => @registration.id, 
          :game_id => @current_game.id
        })
        if @squad.save()
          @registration.update_attribute(:squad, @squad)
        else
          flash[:error] = "You have been successfully registered, but there was a problem creating your squad: " + @squad.errors.full_messages.first
        end
      end

			unless (@registration.person.phone.nil? or @registration.person.phone.empty?)
				Delayed::Job.enqueue SendNotification.new(@person, "Thank you for registering for HvZ. Your card code is: " + @registration.card_code + ". Please keep this code on you at all times. Have fun!")
			end
			redirect_to registration_url(@registration)
		else
			redirect_to new_registration_url()
		end
	end

	def destroy
		@registration = Registration.find(params[:id])
		@registration.delete() unless @registration.nil?
		redirect_to registrations_url()
	end

	def show
		@registration = Registration.find(params[:id])
		if @registration.person_id != @person.id
			flash[:error] = "This is not your registration!!"
			redirect_to root_url()
			return
		end
	end

	def update
		r = Registration.find(params[:id])
		r.update_attributes(params[:registration])
		redirect_to edit_registration_url(params[:id])
	end

	def edit
		@registration = Registration.find(params[:id])
		@person = @registration.person;
		if !@is_admin and @person != @logged_in_person
			flash[:error] = "You do not have permission to edit this registration."
			redirect_to root_url()
			return
		end
	end

	def report
		@registration = Registration.find(params[:id])
		if(!@is_admin)
			flash[:error] = "You do not have permission to report infractions."
			redirect_to root_url()
			return
		end
	end

	def index
		@registrations = Registration.find_all_by_game_id(@current_game.id, :include=>:person)

		@registrations_people = @registrations.map{|x| x.person_id}
		@allpeople = Person.all.map{|x| x if not @registrations_people.include?(x.id)}.compact
	end

  def start_registration_process
    session[:is_registering] = true
    current_waiver = Waiver.find_by_person_id_and_game_id(@logged_in_person.id, @current_game.id)
    if @logged_in_person.name.nil?
      redirect_to edit_person_url(@logged_in_person)
      return false
    end
    if current_waiver.nil?
      redirect_to sign_waiver_url(@logged_in_person)
      return false
    end
  end
  def joinsquad
    if not params[:id].to_i == @logged_in_registration.id.to_i
      flash[:error] = "Error! Trying to sign someone else up into a squad?"
      redirect_to root_url()
      return
    end
    if @logged_in_registration.squad != nil
      flash[:error] = "Error! You cannot change your squad."
      redirect_to root_url()
      return
    end
    unless @current_game.has_begun?
      @logged_in_registration.squad = Squad.find(params[:squadid])
      @logged_in_registration.save()
      redirect_to registration_url(@logged_in_registration)
      return
    end
  end
end
