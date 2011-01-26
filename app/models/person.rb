class Person < ActiveRecord::Base
	has_many :infractions # Though hopefully not!
	has_many :registrations
end
