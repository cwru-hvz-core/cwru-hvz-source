# Right now, this will simply send a SMS message to the
# given player. But eventually, this file will simply be passed
# a message and it will convey it to the player based on their
# notification settings.

class SendNotification
	def initialize(to_player, message)
		@un = Game.current.gv_username
		@pw = Game.current.gv_password
		@to_player = to_player
		@message = message
	end

	def perform
		api = GoogleVoice::Api.new(@un, @pw) unless (@un.empty? or @un.nil?)
		if not @to_player.nil? and api
			begin
				api.sms(@to_player.phone, @message) if (not @to_player.phone.nil?)
			rescue
				puts "Could not log into Google Voice"
			end
		end
	end
end
