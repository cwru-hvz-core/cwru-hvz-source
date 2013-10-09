class WaiverController < ApplicationController
  before_filter :check_login
  before_filter :require_can_register

  def new
    @waiver = Waiver.new.tap do |w|
      w.person = @logged_in_person

      if last_waiver = @logged_in_person.waivers.last
        w.studentid = last_waiver.studentid
      end
    end
  end

  def create
    @logged_in_person.update_attributes(params[:person])

    if !@logged_in_person.legal_to_sign_waiver?
      return redirect_to new_registration_url
    end

    @w = Waiver.new(params[:waiver])
    @w.person = @logged_in_person
    @w.game = @current_game

    # Shame on me for coding these here. They really should be in the validate method of Waiver.
    # TODO: Move them there.

    unless @logged_in_person.legal_to_sign_waiver?
      return render :under18
    end

    if @w.chk1.eql?("0") or @w.chk2.eql?("0") or @w.chk3.eql?("0") or @w.chk4.eql?("0")
      flash[:error] = "Error: You must check all boxes to accept the waiver."
    end
    if not @w.signature.downcase.eql?(@w.person.name.downcase)
      flash[:error] = "Error: You did not sign your name ("+@w.person.name+") correctly."
    end
    if @w.emergencyname.empty? or @w.emergencyphone.empty?
      flash[:error] = "Error: You must provide emergency contact details."
    end
    if @w.studentid.to_s.empty?
      flash[:error] = "Error: You must provide your student ID."
    end

    return redirect_to sign_waiver_path(next: params[:next]) if flash[:error]

    if @w.save
      case params[:next]
      when 'registration'
        redirect_to new_registration_path
      else
        redirect_to sign_waiver_path
      end
    end
  end
end
