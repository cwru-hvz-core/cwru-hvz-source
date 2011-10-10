class IndexController < ApplicationController
	def root
		@players = @current_game.registrations
		@tags = Tag.where(:game_id => @current_game.id).order("datetime DESC").limit(10)
    @checkins = CheckIn.where(:registration_id => @players.map{|x| x.id}).order("created_at DESC").limit(10)
    # Put everything into a hash, items, that has a key with the timestamp.
    # And then use that as a key for sorting.
    @items = {}
    @tags.map{|x| {(x.datetime - @current_game.utc_offset) => x}}.each{|x| @items = @items.merge(x)}
    @checkins.map{|x| {x.created_at => x}}.each{|x| @items = @items.merge(x)}
    @items = @items.sort{|x,y| y <=> x}.map{|x| x[1]}   #Just the item! 
		@ozs = @current_game.ozs
	end
end
