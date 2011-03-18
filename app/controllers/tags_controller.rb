class TagsController < ApplicationController
  before_filter :check_is_registered

  def new
	  @tag = Tag.new
	  if @is_admin
		  @humans = Registration.find_all_by_faction_id(0).sort{|x,y| x.card_code <=> y.card_code}
		  @humans.collect{|x| not x.is_oz}.compact

		  @zombies = Registration.find_all_by_faction_id(1).sort{|x,y| x.card_code <=> y.card_code}
		  @zombies.concat(Registration.find_all_by_is_oz(true))
	  end
  end

  def create
	  @tag = Tag.new(params[:tag])
	  @tag.game = @current_game
      @tag.tagger_id = @logged_in_registration.id if @tag.tagger_id.nil?
	  if @tag.tagee_id.nil?
		  flash[:error] = "Invalid Card Code Specified!"
		  redirect_to new_tag_url()
		  return
	  end
	  @tagee = Registration.find(@tag.tagee_id)
	  @tagger = Registration.find(@tag.tagger_id) unless @tag.tagger_id == 0
	  #TODO: Fix ActiveRecord so we don't have to do this crummy registration loading:
	  @points_given = 0
	  @points_given = @tagee.score*0.2 unless @tag.award_points=="0"
	  @tag.score = @points_given
	  unless @tag.save()
		  flash[:error] = @tag.errors.full_messages.first
		  redirect_to new_tag_url()
	  end
  end
end
