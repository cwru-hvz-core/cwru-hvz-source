class FeedsController < ApplicationController
  before_filter :check_admin

  def create
    if params[:mass_feed] == 'true'
      @mission = Mission.find(params[:mission_id]) if params[:mission_id]

      @current_game.registrations.where(:faction_id => 1).each do |r| # All current zombies
        @feed = Feed.new
        if @mission
          @feed.mission = @mission
          @feed.datetime = @mission.end
        else
          @feed.datetime = Time.now
        end
        @feed.registration = r
        @feed.save
      end

      flash[:message] = "All Zombies Fed"
      if @mission
        redirect_to feeds_mission_path(@mission)
      else
        redirect_to tools_game_path(Game.current)
      end
    else
      @feed = Feed.new(params[:feed])
      if @feed.person_id.nil?
        @feed.person_id = Person.where("lower(name) LIKE ?", params[:feed][:person_name].downcase + "%")
      end
      @mission = Mission.find(params[:feed][:mission_id])
      @feed.datetime = @mission.end
      @feed.save
      @feeds = @mission.feeds.sort{|x,y| y.created_at <=> x.created_at}
    end
    Game.current.touch
  end

end
