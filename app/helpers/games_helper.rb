module GamesHelper
	def get_scoreboard_text(registration)
		if registration.faction_id == 0   # Human
			return "Survived <span class='highlight'>" + (registration.time_survived/3600).round.to_s + "</span> Hours + "
		elsif registration.faction_id == 1   # Zombie
			return "ZOMBIE!"
		else
			return "DECEASED!"
		end
	end
end

def faction_id_to_class(registration)
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
