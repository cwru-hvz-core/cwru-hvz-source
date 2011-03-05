class IndexController < ApplicationController
	def root
		@players = @current_game.registrations
	end
end
