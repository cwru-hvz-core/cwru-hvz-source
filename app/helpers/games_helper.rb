module GamesHelper
	def get_scoreboard_text(registration)
		appears_human = false
		if registration.is_oz and not registration.game.ozs_revealed?
			time_survived = registration.game.since_begin
			appears_human = true
		end
		time_survived ||= registration.time_survived

		if registration.faction_id == 0 or appears_human   # Human
			return "Survived <span class='highlight'>" + (time_survived/1.hour).floor.to_s + "</span> Hours + <span class='highlight'>n</span> Missions"
		elsif registration.faction_id == 1   # Zombie
			dies_in = (registration.state_history[:deceased]-registration.game.utc_offset)-Game.now(registration.game)
			return "<span class='highlight'>" + registration.tagged.length.to_s + "</span> Tags (Starves in less than <span class='highlight'>" + (dies_in/1.hour).ceil.to_s + "</span> Hours)"
		else
			return "DECEASED!"
		end
	end
end

def faction_id_to_class(registration)
	return "human" if registration.is_oz and not registration.game.ozs_revealed?

	case registration.faction_id
	when 0
		return "human"
	when 1
		return "zombie"
	when 2
		return "deceased"
	when nil
		return "deceased"
	else
		return "deceased"
	end
end

def get_total_severity(registration)
	return registration.infractions.sum(:severity)
end
