class IndexController < ApplicationController
	def root
		@players = @current_game.registrations
		@tags = Tag.where(:game_id => @current_game.id).order("datetime DESC").limit(5)
	end
end
