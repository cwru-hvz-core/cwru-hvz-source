class Api::GameController < ApplicationController
  caches_action :players

  def players
    @g = Game.find(params[:id], :include => [{:registrations => :person}])
    render :json => @g.registrations.map{|x| {
      :id => x.id, 
      :current_faction => x.faction_id, 
      :name => x.person.name, 
      :score => x.score, 
      :state_history => x.state_history, 
      :is_oz => @g.ozs_revealed? && x.is_oz,
      :is_admin => x.person.is_admin
      }}
  end

  def info
    g = Game.find(params[:id])
    render :json => {:game_begins => g.game_begins, :game_ends => g.game_ends, :registration_begins => g.registration_begins, :registration_ends => g.registration_ends, :now => Game.now(g), :oz_reveal => g.oz_reveal}
  end
end
