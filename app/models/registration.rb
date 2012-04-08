class Registration < ActiveRecord::Base
  require './lib/phpbb_utility.rb'
	belongs_to :person
	belongs_to :game
  belongs_to :squad
  has_one :waiver
	has_many :infractions
	has_many :feeds
	has_many :missions, :class_name => "Attendance"
	has_many :has_fed, :foreign_key => "feeder_id"
	has_many :tagged, :foreign_key => "tagger_id", :class_name => "Tag"
	has_many :taggedby, :foreign_key => "tagee_id", :class_name => "Tag"
  has_many :check_ins
  has_many :bonus_codes

	validates_uniqueness_of :person_id, :scope => :game_id	
	validates_uniqueness_of :card_code, :scope => :game_id
	validates_presence_of :person_id, :game_id, :card_code

	def self.make_code
		chars = %w{ A B C D E F 1 2 3 4 5 6 7 8 9 }
		(0..5).map{ chars.to_a[rand(chars.size)] }.join
	end
	def display_score
		if self.is_oz and not self.game.ozs_revealed?
			return self.game.mode_score
		end
		self.score
	end	
	def validate
		errors.add_to_base("Registration has not yet begun for this game!")	if (Time.now + self.game.utc_offset) < self.game.registration_begins
		errors.add_to_base("Registration has already ended for this game!") if (Time.now + self.game.utc_offset) > self.game.registration_ends
	end

	# Note: These methods are costly and should only be called asynchronously.
	
	def time_survived
		return 0 if self.is_oz
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

	def total_deaths_associated
		# Recursively finds the number of deaths
		# that were involved with a player. Note: This
		# returns 1 for zombies without kills (because
		# they died themselves)
		killing_tag = self.killing_tag
		retval = 0
		if killing_tag.nil?     # E.g. the player is an OZ or human
			retval = self.tagged.map{|x| x.count_resulting_tags}.sum
		else
			retval = killing_tag.count_resulting_tags
		end
		retval += 1 if self.is_oz
		return retval
	end
	
	def zombietree_json
		#recursively generates json data for this player's family tree.
		#(the following code uses & as string delimiter
		#	to make things nicer)
		json = %&{id:"player#{self.id}",name:"#{self.person.name}",data:{tags:#{self.tagged.length}},children:[&
		children = self.tagged(:include=>[:tagged,:person]).collect{|x| x.tagee.zombietree_json}.compact
		json += %&#{ children.to_sentence(:last_word_connector => ",", :two_words_connector => ",") unless children.empty?}]}&
	end
	
	def most_recent_feed
		# Does not adjust for UTC offset!
		# Get the time the player turned into a zombie:
		tag = self.killing_tag
		zombietime = tag.datetime + 1.hour unless tag.nil?
		zombietime = self.game.game_begins if self.is_oz
		zombietime ||= Time.at(0)
		# Get the most recent tag that player has made:
		tag = self.tagged.sort{|a,b| b.datetime <=> a.datetime}.first
		tagtime = tag.datetime unless tag.nil?
		tagtime ||= Time.at(0) # (if they have no tags)
		# Get the most recent feed that player has been given:
		feed = self.feeds.sort{|a,b| b.datetime <=> a.datetime}.first
		feedtime = feed.datetime unless feed.nil?
		feedtime ||= Time.at(0) # (if they have no feeds)
		return [zombietime, feedtime, tagtime].max
	end
	def time_until_death
		return (self.most_recent_feed - self.game.utc_offset + 48.hours)  - Time.now
	end

	def is_human?
		# A player is human if and only if they have not been tagged in game (i.e. outside a mission)
		self.killing_tag.nil? and not self.is_oz
	end
	def is_zombie?
		# A player is a zombie if they have been tagged in game and have not yet starved.
		return true if self.is_oz and self.most_recent_feed + 48.hours >= Game.now(self.game)+Game.current.utc_offset
		return (!self.killing_tag.nil? and self.most_recent_feed + 48.hours >= Game.now(self.game)+Game.current.utc_offset)
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

	def ==(other)
		return false if self.nil? || other.nil?
		return false if not (self.is_a?(Registration) && other.is_a?(Registration))
		self.id == other.id
	end
    def phpbb_convert_to_faction(faction_id)
      # Faction id: Human => 0, Zombie => 1, Deceased => 2
      @conn = self.game.connect_to_phpbb()
      if @conn
        ids = PHPBBUtility.get_user_ids(@conn, card_code)
        convert_stmt = @conn.prepare("DELETE FROM phpbb_user_group WHERE group_id = ? AND user_id = ?")
        add_stmt = @conn.prepare("INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (?, ?, 0, 0)")
        ids.each do |id|
          convert_stmt.execute(self.game.phpbb_human_group, id)
          convert_stmt.execute(self.game.phpbb_zombie_group, id)
          case faction_id
          when 0
            add_stmt.execute(self.game.phpbb_human_group, id)
          when 1
            add_stmt.execute(self.game.phpbb_zombie_group, id)
          end
        end
        convert_stmt.close()
        add_stmt.close()
        PHPBBUtility.clear_permissions(@conn, ids)
      end
    end
end
