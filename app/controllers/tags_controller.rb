class TagsController < ApplicationController
  before_filter :check_is_registered

  def new
	  if @logged_in_registration.is_human? and not @is_admin
			flash[:error] = "You are not a Zombie, so you cannot report tags!"
			redirect_to root_url()
			return
	  end
	  @tag = Tag.new
    @zombies = Registration.where(:game_id => @current_game, :faction_id => 1).
      includes(:tagged, :taggedby, :feeds, :missions, :person).
      sort_by { |x| [ (x.time_until_death / 1.hour).ceil, -x.tagged.length ] }

	  if @is_admin
		  @humans = Registration.find_all_by_game_id_and_faction_id(@current_game.id, 0, :include=>[:person]).sort{|x,y| x.card_code <=> y.card_code}
		  @humans.collect{|x| not x.is_oz}.compact
  
      # Add all the deceased zombies.
		  @zombies.concat(Registration.find_all_by_game_id_and_faction_id(@current_game.id, 2))
	  end
	  
    @zombiebox = @zombies.map do |x|
      if x.time_until_death > 0
        ["#{x.person.name} (#{x.missions.length} missions, #{x.tagged.length} tags, #{(x.time_until_death/1.hour).ceil} hours left) ", x.id]
        else
        ["#{x.person.name} (Deceased)", x.id]
      end
    end
  end

  def create
	  #TODO: This is really ugly.
	  @tag = Tag.new(params[:tag])
	  @tag.game = @current_game
	  if @tag.tagee_id.nil?
		  flash[:error] = "Invalid Card Code Specified!"
		  redirect_to new_tag_url()
		  return
	  end
	  if not params[:tag_meta].nil? and params[:tag_meta][:is_admin_tag] == "true"
		  @tag.admin = @logged_in_person
		  @tag.tagger_id = params[:tag][:tagger_id]
	  else 
		  if @tag.tagger_id == 0
			  flash[:error] = "Invalid Admin Action Detected!"
			  redirect_to new_tag_url()
			  return
		  end
	  end
      @tag.tagger = @logged_in_registration if @tag.tagger.nil?
	  @points_given = 0
	  @points_given = @tag.tagee.score*0.2 unless @tag.award_points=="0"
	  @tag.score = @points_given
	  unless @tag.save()
		  flash[:error] = @tag.errors.full_messages.first
		  redirect_to new_tag_url()
		  return
	  end
	  # Now that the tag has saved, let's process the extra feeds!
	  @feed1 = Feed.new
	  @feed2 = Feed.new

	  unless @tag.feed_1.empty?
		  @feed1.tag = @tag
		  @feed1.registration_id = @tag.feed_1
		  @feed1.datetime = @tag.datetime
		  @feed1.save()
	  end

	  unless @tag.feed_2.empty?
		  @feed2.tag = @tag
		  @feed2.registration_id = @tag.feed_2
		  @feed2.datetime = @tag.datetime
		  @feed2.save()
	  end
	  Delayed::Job.enqueue SendNotification.new(:tag, @tag, @feed1, @feed2)
  end
end
