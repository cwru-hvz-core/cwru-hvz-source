class ContactMessage < ActiveRecord::Base
	belongs_to :game
	validates_presence_of :body
	

	def validate
		if self.occurred >= (Time.now + Time.zone_offset(self.game.time_zone))
			errors.add(:occurred, "is in the future.")
		end
	end
end
