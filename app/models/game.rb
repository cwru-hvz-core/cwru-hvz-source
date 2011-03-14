class Game < ActiveRecord::Base
	require './lib/game_validator.rb' # A better way??
	has_many :registrations
	has_many :tags
	has_many :missions
	has_many :contact_messages
	validates_with GameValidator  # Defined in ./lib/game_validator.rb

	def self.current
		Game.find(:first, :conditions => ["is_current = ?", true]) or Game.new
	end

	def dates
	# Method to return all the human-readable dates for a game
		datetimeformat = "%A, %B %e, %Y @ %I:%M %p"
		array = {	:date_range => game_begins.strftime("%B %e") + " - " + game_ends.strftime("%e"), 
			:registration_begins => registration_begins.strftime(datetimeformat),
			:registration_ends => registration_ends.strftime(datetimeformat),
			:game_begins => game_begins.strftime(datetimeformat),
			:game_ends => game_ends.strftime(datetimeformat)
		}
		if game_ends.month != game_begins.month
			array[:date_range] =  game_begins.strftime("%B %e") + " - " + game_ends.strftime("%B %e") 
		end
		return array
	end
	def ongoing?
		return false if self.game_begins.nil? or self.game_ends.nil?
		self.has_begun? and not self.has_ended?
	end
	def has_begun?	
		Time.now + self.utc_offset >= self.game_begins
	end
	def has_ended?
		Time.now + self.utc_offset >= self.game_ends
	end
	def can_register?
		(self.registration_begins < Time.now.utc) and (self.registration_ends > Time.now.utc)
	end

	def self.now(game)
		# Returns the effective time so states won't change after the game ends. (Hopefully)
		[Time.now.utc, game.game_ends].min
	end
	def utc_offset
		dst_off = 0
		dst_off = 1.hour if Time.now.dst?
		ActiveSupport::TimeZone.new(self.time_zone).utc_offset + dst_off
	end
#	def game_begins=(value)
#		write_attribute(:game_begins, value) unless has_begun?
#	end
#	def game_ends=(value)
#		assign_multiparameter_attributes(:game_ends, value) unless has_ended?
#	end
end

