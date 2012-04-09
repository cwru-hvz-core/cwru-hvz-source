class SquadController < ApplicationController
  before_filter :check_is_registered, :only => [:index]

  def show
        
  end

  def index
    @squads = @current_game.squads.includes({:registrations => :person}).sort_by{|x| x.points/x.registrations.length}.reverse
  end

end
