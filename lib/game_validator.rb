class GameValidator < ActiveModel::Validator
	def validate(record)
		record.errors[:short_name] << "cannot be blank" if record.short_name.empty?
		record.errors[:game_ends] << "precedes start of game" if not check_game_dates(record)
		record.errors[:registration_ends] << "precedes start of registration" if not check_registration_dates(record)
	end

	def check_game_dates(record)
		return record.game_ends > record.game_begins
	end
	def check_registration_dates(record)
		return record.registration_ends > record.registration_begins
	end
end
