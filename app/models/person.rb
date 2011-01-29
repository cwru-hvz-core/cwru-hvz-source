class Person < ActiveRecord::Base
	has_many :infractions # Though hopefully not!
	has_many :registrations

	attr_accessible :name, :phone # The user-modifiable fields
end
