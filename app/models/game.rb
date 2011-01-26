class Game < ActiveRecord::Base
	has_many :registrations
	has_many :tags
	has_many :missions
end
