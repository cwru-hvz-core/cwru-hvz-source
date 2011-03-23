class TagsController < ApplicationController
  before_filter :check_is_registered

  def new
	  if @logged_in_registration.is_human?
			flash[:error] = "You are not a Zombie, so you cannot report tags!"
			redirect_to root_url()
			return
	  end
	  @tag = Tag.new
	  @zombies = Registration.find_all_by_faction_id(1).sort{|x,y| x.time_until_death <=> y.time_until_death}
	  
	  if @is_admin
		  @humans = Registration.find_all_by_faction_id(0).sort{|x,y| x.card_code <=> y.card_code}
		  @humans.collect{|x| not x.is_oz}.compact

		  @zombies.concat(Registration.find_all_by_faction_id(2))
	  end
	  
	  @zombiebox = @zombies.collect{|x| 
		  if x.time_until_death > 0
			  [x.person.name + " (" + (x.time_until_death/1.hour).ceil.to_s + " hours left) ", x.id]
	  	  else
			  [x.person.name + " (Deceased)", x.id]
		  end
	  }
  end

  def create
	  #TODO: This is really ugly.
	  @tag = Tag.new(params[:tag])
	  @tag.game = @current_game
      @tag.tagger = Registration.find_by_game_id_and_person_id(@current_game, @logged_in_person.id) if @tag.tagger.nil?
	  if @tag.tagee_id.nil?
		  flash[:error] = "Invalid Card Code Specified!"
		  redirect_to new_tag_url()
		  return
	  end
	  if not params[:tag_meta].nil? and params[:tag_meta][:is_admin_tag] == "true"
		  @tag.admin = @logged_in_person
	  else 
		  if @tag.tagger_id == 0
			  flash[:error] = "Invalid Admin Action Detected!"
			  redirect_to new_tag_url()
			  return
		  end
	  end
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
