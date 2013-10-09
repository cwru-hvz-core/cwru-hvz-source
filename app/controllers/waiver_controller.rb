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

    @w = Waiver.where(person_id: @logged_in_person, game_id: @current_game).
      first_or_initialize(params[:waiver])

    unless @logged_in_person.legal_to_sign_waiver?
      return render :under18
    end

    if !@w.valid?
      flash[:error] = @w.errors.full_messages.first
    end

    if %w[chk1 chk2 chk3 chk4].any? { |n| params[:confirmation][n] == '0' }
      flash[:error] = 'Error: You must check all boxes to accept the waiver.'
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
