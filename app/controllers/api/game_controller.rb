class Api::GameController < ApplicationController
  def show

    if params[:type] == "players"
      @g = Game.find(params[:id], :include => [{:registrations => :person}])
      render :json => @g.registrations.map{|x| {:id => x.id, :current_faction => x.faction_id, :name => x.person.name, :score => x.score, :state_history => x.state_history}}
    end
  end
end
