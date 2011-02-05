class Game < ActiveRecord::Base
	require './lib/game_validator.rb' # A better way??
	has_many :registrations
	has_many :tags
	has_many :missions
	validates_with GameValidator

end

