class Person < ActiveRecord::Base
	has_many :infractions # Though hopefully not!
	has_many :registrations
	validates :caseid, :presence => true

	attr_accessible :name, :phone # The user-modifiable fields
end
