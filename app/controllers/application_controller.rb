class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_game,
                :set_time_zone,
                :set_logged_in_person

  def set_game
    @current_game = Game.current
  end

  def set_time_zone
    Time.zone = @current_game.time_zone
  end

  def set_logged_in_person
    @is_admin ||= false

    if session[:cas_user].present?
      @logged_in_person = Person.where(caseid: session[:cas_user]).first_or_create
      # todo[tdooner]: %s/@person/@logged_in_person/
      @person = @logged_in_person
      @is_admin = @logged_in_person.is_admin
    end
  end

  def check_admin
    unless @is_admin
      redirect_to root_url
    end
  end

  def check_login
    if session[:cas_user].nil?
      session[:was_at] = request.env['PATH_INFO']
      redirect_to people_login_url
    else
      @logged_in_person = Person.where(caseid: session[:cas_user]).first_or_create
    end
  end

  def check_is_registered
    @logged_in_registration = Registration.where(person_id: @logged_in_person, game_id: @current_game).first
    if @logged_in_registration.nil?
      flash[:error] = "You must register for the game before you can view this page."
      redirect_to root_url
    end
  end

  def require_can_register
    if !@current_game.can_register?
      if @current_game.registration_begins.blank? || @current_game.registration_ends.blank?
        flash[:error] = 'Registration times for this game have not yet been configured'
      end

      if @current_game.now < @current_game.registration_begins
        flash[:error] = "Registration begins #{@current_game.to_s(:registration_begins)}. Please check back then!"
      end

      if @current_game.now > @current_game.registration_ends
        flash[:error] = "Registration ended #{@current_game.to_s(:registration_ends)}. If you would still like to play, please contact the administrators."
      end

      return redirect_to root_url
    end
  end
end
