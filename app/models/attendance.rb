class Attendance < ActiveRecord::Base
	belongs_to :registration
	belongs_to :mission

	validates_uniqueness_of :registration_id, :scope => :mission_id
	validates_presence_of :registration_id, :mission_id

	attr_accessor :person_id, :person_name

	def person_id=(value)
		self.registration = Registration.find_by_game_id_and_person_id(Game.current.id, value)
	end
end
