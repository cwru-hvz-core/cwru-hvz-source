class Registration < ActiveRecord::Base
	belongs_to :person
	belongs_to :game
	has_many :infractions
	has_many :feeds
	has_many :attendances
	has_many :has_fed, :foreign_key => "feeder_id"
	has_many :tagged, :foreign_key => "tagger_id", :class_name => "Tag"
	has_many :taggedby, :foreign_key => "tagee_id", :class_name => "Tag"

	validates_uniqueness_of :person_id, :scope => :game_id
	validates_presence_of :person_id, :game_id, :card_code

	def self.make_code
		chars = %w{ A B C D E F 1 2 3 4 5 6 7 8 9 }
		(0..5).map{ chars.to_a[rand(chars.size)] }.join
	end
	
	def validate
		errors.add_to_base("Registration has not yet begun for this game!")	if (Time.now + self.game.utc_offset) < self.game.registration_begins
		errors.add_to_base("Registration has already ended for this game!") if (Time.now + self.game.utc_offset) > self.game.registration_ends
	end

	# Note: These methods are costly and should only be called asynchronously.
	
	def time_survived
		tag = self.killing_tag
		real_begins = self.game.game_begins - self.game.utc_offset
		return [0, tag.datetime - real_begins].max unless tag.nil?
		return [0, Game.now(self.game) - real_begins].max
	end

	def killing_tag
		# Each human should have only one killing tag. (That is, the tag that turned them
		# into a zombie)
		self.taggedby.map{|x| x if x.mission_id.nil? or x.mission_id==0 }.compact.first
	end

	def most_recent_feed
		# Get the time the player turned into a zombie:
		tag = self.killing_tag
		zombietime = tag.datetime + 1.hour unless tag.nil?
		zombietime ||= Time.at(0)
		# Get the most recent feed given to that player:
		feedtime = self.tagged.sort{|a,b| b.datetime <=> a.datetime}.first
		feedtime = feedtime.datetime unless feedtime.nil?
		feedtime ||= Time.at(0) # (if they have no feeds)
		return [zombietime, feedtime].max
	end

	def is_human?
		# A player is human if and only if they have not been tagged in game (i.e. outside a mission)
		self.killing_tag.nil?
	end
	def is_zombie?
		# A player is a zombie if they have been tagged in game and have not yet starved.
		return (!self.killing_tag.nil? and self.most_recent_feed + 48.hours >= Game.now(self.game))
	end
	def is_deceased?
		# A player is deceased if they are not human and not a zombie.
		return (!self.is_human? and !self.is_zombie?)
	end
	def state_history
		# Returns the times at which the human transitioned between factions, according to the
		# current database.
		# TODO: Add OZ logic in here
		# Currently only used in the graph of game vs. time in games#show.
		human_time = self.game.game_begins
		tag = self.killing_tag
		zombie_time = self.game.game_ends
		deceased_time = self.game.game_ends
		if self.is_oz
			zombie_time = self.game.game_begins
			deceased_time = [self.game.game_begins, self.most_recent_feed].max + 48.hours
		end
		if not tag.nil?
			zombie_time = tag.datetime + 1.hour 
			deceased_time = self.most_recent_feed + 48.hours
		end
		return {:human => human_time, :zombie => zombie_time, :deceased => deceased_time}
	end
end
