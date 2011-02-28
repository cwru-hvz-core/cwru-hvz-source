#TODO: This file should contain the logic to, at any point,
# determine based on the database state, precisely who is
# human, zombie, and deceased. This script should also calculate
# point totals.
#
# Note: This file is responsible for being the correct
# judge of the current state. This file should update the following
# 'caches' of the current state -- so it can be easily
# accessed elsewhere:
#   registration.faction_id
#   registration.score
#
# Also, this file should store the current game state in the database
# if it has changed -- so all changes can be tracked over time.

class UpdateGameState
	def initialize
		@current_game = Game.current
	end

	def perform
		@players = @current_game.registrations

		@human_faction = @players.map{|p| 
			p if p.is_human?
		}.compact

		@zombie_faction = @players.map{|p|
			p if p.is_zombie?
		}.compact
	
		@deceased_faction = @players.map{|p|
			p if p.is_deceased?
		}.compact

		update_faction_cache({:human => @human_faction,
					  :zombie => @zombie_faction,
					  :deceased => @deceased_faction
		})
	end

	def update_faction_cache(factions)
		factions[:human].each do |h|
			h.update_attributes({:faction_id => 0})
		end
		factions[:zombie].each do |h|
			h.update_attributes({:faction_id => 1})
		end
		factions[:deceased].each do |h|
			h.update_attributes({:faction_id => 2})
		end
	end

	def update_score_cache(registrations)

	end
end
