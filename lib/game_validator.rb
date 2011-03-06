class GameValidator < ActiveModel::Validator
	def validate(record)
		record.errors[:short_name] << "cannot be blank" if record.short_name.empty?
		record.errors[:game_ends] << "precedes start of game" if not check_game_dates(record)
		record.errors[:game_begins] << "precedes registration end" if not check_registration_precedes_game(record)
		record.errors[:game_ends] << "makes the game too long. The maximum game length supported is 20 days." if not check_game_length(record)
		record.errors[:registration_ends] << "precedes start of registration" if not check_registration_dates(record)
	end

	def check_game_dates(record)
		return record.game_ends > record.game_begins
	end
	def check_registration_dates(record)
		return record.registration_ends > record.registration_begins
	end
	def check_registration_precedes_game(record)
		return record.game_begins > record.registration_ends
	end
	def check_game_length(record)
		return (record.game_ends - record.game_begins) < 20.days
	end
end
