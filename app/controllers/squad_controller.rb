class SquadController < ApplicationController
  before_filter :check_is_registered, :only => [:index]

  def show
        
  end

  def index
    @squads = @current_game.squads
  end

end
