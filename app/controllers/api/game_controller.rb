class Api::GameController < ApplicationController
  def show

    if params[:type] == "players"
      @g = Game.find(params[:id], :include => [{:registrations => :person}])
      render :json => @g.registrations.map{|x| {:id => x.id, :current_faction => x.faction_id, :name => x.person.name, :score => x.score, :state_history => x.state_history}}
    end

    if params[:type] == "info"
      g = Game.find(params[:id])
      render :json => {:game_begins => g.game_begins, :game_ends => g.game_ends, :registration_begins => g.registration_begins, :registration_ends => g.registration_ends}
    end
  end
end
