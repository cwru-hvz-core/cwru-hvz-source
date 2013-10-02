class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :setup

  def setup
    @current_game = Game.current
    Time.zone = @current_game.time_zone

    # If they're logged in, we'll grab detect if they're an admin
    @logged_in = !session[:cas_user].nil?
    @is_admin ||= false
    if @logged_in
      @logged_in_person = Person.find_or_create_by_caseid(session[:cas_user])
      @person = Person.find_by_caseid(session[:cas_user])
      @is_admin ||= @person.is_admin unless @person.nil?
    end
  end

  def check_admin
    unless @is_admin
      redirect_to root_url and return
    end
  end

  def check_login
    if session[:cas_user].nil?
      session[:was_at] = request.env['PATH_INFO']
      redirect_to people_login_url and return
    else
      @logged_in_person = Person.find_or_create_by_caseid(session[:cas_user])
    end
  end

  def check_is_registered
    @logged_in_registration = Registration.find_by_person_id_and_game_id(@logged_in_person,@current_game)
    if @logged_in_registration.nil?
      flash[:error] = "You must register for the game before you can view this page."
      redirect_to root_url and return
    end
  end
end
