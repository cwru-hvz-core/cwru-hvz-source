class Person < ActiveRecord::Base
	has_many :infractions # Infractions submitted by this admin
	has_many :registrations
	validates :caseid, :presence => true

	attr_accessible :name, :phone # The user-modifiable fields

	def phone=(arg)
		write_attribute(:phone, arg.gsub(/[^\d]/){|x| })
	end
	def ==(other)
		return false if self.nil? or other.nil?
		self.caseid == other.caseid
	end
end
