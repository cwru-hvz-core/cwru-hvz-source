class FeedsController < ApplicationController
	before_filter :check_admin

  def create
	  @feed = Feed.new(params[:feed])
	  @mission = Mission.find(params[:feed][:mission_id])
	  @feed.datetime = @mission.end
	  @feed.save()
	  @feeds = @mission.feeds.sort{|x,y| y.created_at <=> x.created_at}
  end

end
