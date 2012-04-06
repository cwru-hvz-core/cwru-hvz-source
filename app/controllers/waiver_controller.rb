class WaiverController < ApplicationController
  before_filter :check_login
  before_filter :check_for_waiver

  def new
    if !@current_game.can_register?
      flash[:error] = "Registration for this game is not open at this time. Registration is open from #{@current_game.dates[:registration_begins]} to #{@current_game.dates[:registration_ends]}"
      return redirect_to root_url()
    end
    last_waiver = @logged_in_person.waivers.last
    if last_waiver
      @w = Waiver.new({:person_id => @logged_in_person, :dateofbirth => last_waiver.dateofbirth, :studentid => last_waiver.studentid})
    else
      @w = Waiver.new({:person_id => @logged_in_person})
    end
  end

  def create
    @w = Waiver.new(params[:waiver])
    @w.person = @logged_in_person
    @w.game = @current_game

    # Shame on me for coding these here. They really should be in the validate method of Waiver.
    # TODO: Move them there.

    if @w.chk1.eql?("0") or @w.chk2.eql?("0") or @w.chk3.eql?("0") or @w.chk4.eql?("0")
      flash[:error] = "Error: You must check all boxes to accept the waiver."
      render :new
      return
    end
    if not @w.signature.downcase.eql?(@w.person.name.downcase)
      flash[:error] = "Error: You did not sign your name ("+@w.person.name+") correctly."
      render :new
      return
    end
    if @w.emergencyname.empty? or @w.emergencyphone.empty?
      flash[:error] = "Error: You must provide emergency contact details."
      render :new
      return
    end
    if @w.studentid.to_s.empty?
      flash[:error] = "Error: You must provide your student ID."
      render :new
      return
    end
    if @w.save()
      redirect_to new_registration_url()
      return
    end
  end

  def check_for_waiver
    current_waiver = Waiver.find_by_person_id_and_game_id(@logged_in_person.id, @current_game.id)

    if session[:is_registering] and not current_waiver.nil?
      redirect_to new_registration_url()
      return false
    end
    if not current_waiver.nil?
      flash[:message] = "You have already signed the waiver!"
      redirect_to root_url()
      return false
    end
  end
end
