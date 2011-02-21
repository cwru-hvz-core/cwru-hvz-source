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

	# Note: These methods is costly and should only be called asynchronously.
	def is_human?
		# A player is human if and only if they have not been tagged in game (i.e. outside a mission)
		not self.taggedby.map{|x| "zombie" if x.mission_id.nil? or x.mission_id==0 }.include?("zombie")
	end

	#TODO: Extract the common code in these methods into a method for most_recent_feed and has_game_tag
	# So we can do:  is_deceased = has_game_tag? and (most_recent_feed + 48.hours < Time.now)
	#                is_zombie = has_game_tag? and (most_recent_feed + 48.hours >= Time.now)
	def is_zombie?
		# A player is zombie if and only if they have been tagged in game and have not deceased.
		#
		# Get the non-mission tags for this player first:
		tags = self.taggedby.map{|x| x if x.mission_id.nil? or x.mission_id==0 }.compact
		
		# If the player has been tagged during the game...
		if not tags.empty?
			# Get the most recent tag
			tagtime = Time.at(0)
			tags.each do |t|
				if t.datetime > tagtime
					tagtime = t.datetime
				end
			end
			# and add the incubation period...
			zombietime = tagtime + 1.hour

			#Get the most recent feed of a player
			feedtime = self.feeds.sort{|a,b| b.datetime <=> a.datetime}.first
			feedtime = feedtime.datetime unless feedtime.nil?
			feedtime ||= Time.at(0)

			#Death occurs 48 hours after the most recent feed or zombification time
			death = [zombietime, feedtime].max + 48.hours

			return !(death < Time.now)
		else
			return false
		end
	end
	def is_deceased?
		# A player is deceased if and only if they have been tagged in game and it is been 48
		# hours since their last tag and feed.
		#
		# Get the non-mission tags for this player first:
		tags = self.taggedby.map{|x| x if x.mission_id.nil? or x.mission_id==0 }.compact
		
		# If the player has been tagged during the game...
		if not tags.empty?
			# Get the most recent tag
			tagtime = Time.at(0)
			tags.each do |t|
				if t.datetime > tagtime
					tagtime = t.datetime
				end
			end
			# and add the incubation period...
			zombietime = tagtime + 1.hour

			#Get the most recent feed of a player
			feedtime = self.feeds.sort{|a,b| b.datetime <=> a.datetime}.first
			feedtime = feedtime.datetime unless feedtime.nil?
			feedtime ||= Time.at(0)

			#Death occurs 48 hours after the most recent feed or zombification time
			death = [zombietime, feedtime].max + 48.hours

			return (death < Time.now)
		else
			return false
		end
	end
end
