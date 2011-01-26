class Mission < ActiveRecord::Base
	belongs_to :game
	has_many :attendances
end
