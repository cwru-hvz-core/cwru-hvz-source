class Api::GameController < ApplicationController
  caches_action :players

  def players
    @g = Game.find(params[:id], :include => [{:registrations => :person}])
    render :json => @g.registrations.map{|x| {
      :id => x.id, 
      :current_faction => x.faction_id, 
      :name => x.person.name, 
      :static_score => x.score, 
      :state_history => Hash[x.state_history.map{|x,y| [x, y.to_i * 1000]}],
      :is_oz => @g.ozs_revealed? && x.is_oz,
      :is_admin => x.person.is_admin
      }}
  end

  def info
    g = Game.find(params[:id])
    render :json => 
    {
      :game_begins => g.game_begins.to_i * 1000, 
      :game_ends => g.game_ends.to_i * 1000, 
      :registration_begins => g.registration_begins.to_i * 1000, 
      :registration_ends => g.registration_ends.to_i * 1000, 
      :now => Game.now(g).to_i * 1000,
      :name => g.short_name,
      :oz_reveal => g.oz_reveal.to_i * 1000,
      :points_per_hour => 50
    }
  end

  def squads
    @g = Game.find(params[:id], :include => [{:squads => :registrations}])
    render :json => @g.squads.map{|x| {
      :id => x.id,
      :leader_id => x.leader_id,
      :name => x.name,
      :members => x.registrations.map{ |y|
          y.id
        }
      }
    }
  end

  def tags
    @g = Game.find(params[:id], :include => [:tags])
    render :json => @g.tags.map{|x| { 
        :id => x.id,
        :tagger_id => x.tagger_id,
        :tagged_id => x.tagee_id,
        :score => x.score,
        :datetime => x.datetime.to_i * 1000,
        :administrative => !(x.admin_id.nil?) && x.tagger_id == 0
      }
    }
  end
end
