class Tag < ActiveRecord::Base
	has_many :registrations, :foreign_key => "tagger_id"
	has_many :registrations, :foreign_key => "tagee_id"
	has_many :feeds
	belongs_to :game
	belongs_to :admin, :class_name => "Person", :foreign_key => "admin_id"

	# TODO: Write code so additional feeds are scalable
	attr_accessor :tagee_card_code, :award_points, :feed_1, :feed_2

	def tagee_card_code=(code)
		tagee = Registration.find_by_card_code(code)
		self.tagee_id = tagee.id unless tagee.nil?
	end

	def validate
		if self.tagger_id.nil?
			errors.add(:tagger_id, "cannot be empty!")
			return
		end
		if self.tagee_id.nil?
			errors.add(:tagee_id, "cannot be empty!")
			return
		end
		unless self.tagger_id == 0
			#TODO: Get ActiveRecord associations working so we don't have to look up registrations this way.
			tagger = Registration.find(self.tagger_id)
			errors.add_to_base "Tagger is not a zombie!" unless (tagger.is_zombie? or tagger.is_oz)
			# Check to ensure the tagger was a zombie at the time the player was tagged.
			if self.datetime < tagger.state_history[:zombie]
				errors.add_to_base "Tag occurred before the tagging player was a zombie!"
			end
		end
		tagee = Registration.find(self.tagee_id)
		errors.add_to_base "Tagged player is not a human!" unless tagee.is_human?

		errors.add_to_base "Tag occurred before game started!" if self.datetime < self.game.game_begins
		errors.add_to_base "Tag occurs after game ends!" if self.datetime >= self.game.game_ends

		errors.add_to_base "Tag occurs in the future?!" if self.datetime-self.game.utc_offset>=Game.now(self.game)

	end
end
