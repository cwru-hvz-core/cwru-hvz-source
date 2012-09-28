class SquadController < ApplicationController
  before_filter :check_is_registered, :only => [:index]

  def show
    @squad = Squad.find(params[:id], :include=>{:registrations => [:person, :tagged]})
  end

  def index
    @squads = @current_game.squads(:includes => [:registrations => :person]).
      select { |x| x.registrations.length > 0 }.
      sort_by{ |x| x.points/x.registrations.length }.
      reverse
  end

end
