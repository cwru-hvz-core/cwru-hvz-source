class CheckInsController < ApplicationController
  before_filter :check_is_registered
  before_filter :can_check_in
  before_filter :check_admin, :only => [:index]

  def index
    @players = Registration.find_all_by_game_id_and_is_off_campus(@current_game.id, true, :include=>[:check_ins, :person])
    @day_count = ((@current_game.game_ends - @current_game.game_begins)/1.day).ceil 
    @current_day = (Game.now(@current_game) - @current_game.game_begins)/1.day
  end

  def new

  end

  def create
    if @valid and @hours_since_last > 6
      begin
        @hostname = Socket.gethostbyaddr(request.remote_ip.split(".").map{|x| x.to_i}.pack("CCCC"))[0]
        c=CheckIn.new({:registration_id => @logged_in_registration.id, :hostname => @hostname})
        c.save()
        flash[:message] = "Checked in on " + @hostname.to_s + " at " + c.created_at.to_s
        redirect_to root_url()
      rescue
        flash[:error] = "Error checking in! Please report this bug."
        redirect_to check_in_url()
      end
    else
      flash[:error] = "Error: You cannot check in right now."
      redirect_to check_in_wizard_url()
    end
  end

  def can_check_in
    @other_checkins = @logged_in_registration.check_ins.sort{|a,b| b.created_at <=> a.created_at}.first
    unless @other_checkins.nil?
      @hours_since_last = (Game.now(@current_game) - @other_checkins.created_at)/1.hour
    else
      @hours_since_last = 10 #It's larger than 6.
    end
    begin
      @hostname = Socket.gethostbyaddr(request.remote_ip.split(".").map{|x| x.to_i}.pack("CCCC"))[0]
      @location = CheckIn.get_location(@hostname) # Either "Wade" or "Nord"
      if @location != nil
        @valid = CheckIn.is_valid_place_and_time?(@location, Game.now(@current_game).utc + @current_game.utc_offset)
      end
    rescue
      @hostname = nil
      @location = nil
      @valid = false
    end
  end

end
