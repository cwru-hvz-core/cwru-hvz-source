class WaiverController < ApplicationController
  before_filter :check_login

  def new
    if !@current_game.can_register?
      flash[:error] = "Registration for this game is not open at this time. Registration is open from #{@current_game.to_s(:registration_begins)} to #{@current_game.to_s(:registration_ends)}"
      return redirect_to root_url
    end

    if last_waiver = @logged_in_person.waivers.last
      @w = Waiver.new(
        person_id: @logged_in_person,
        studentid: last_waiver.studentid,
      )
    else
      @w = Waiver.new(person_id: @logged_in_person)
    end
  end

  def create
    @logged_in_person.update_attribute(:date_of_birth, params[:waiver][:dateofbirth])

    if !@logged_in_person.legal_to_sign_waiver?
      return redirect_to new_registration_url
    end

    @w = Waiver.new(params[:waiver])
    @w.person = @logged_in_person
    @w.game = @current_game

    # Shame on me for coding these here. They really should be in the validate method of Waiver.
    # TODO: Move them there.

    @age = (@current_game.game_begins.to_date - @w.dateofbirth) * 1.day / 1.year
    if @age < 18
      return render :under18
    end

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
end
