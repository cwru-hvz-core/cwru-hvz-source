# Right now, this will simply send a SMS message to the
# given player. But eventually, this file will simply be passed
# a message and it will convey it to the player based on their
# notification settings.
#
# So, either call this like:
# Delayed::Job.enqueue SendNotification.new(@person, "Message")
# -- or --
# Delayed::Job.enqueue SendNotification.new([[@person1, "Message1"], [@person2, "message2"]])

class SendNotification
	def initialize(*params)
		@un = Game.current.gv_username
		@pw = Game.current.gv_password
		if params[0].kind_of?(Array)
			@mass_text = params[0]
		else
			@to_player = params[0]
			@message = params[1]
		end
	end

	def perform
		api = GoogleVoice::Api.new(@un, @pw) unless (@un.empty? or @un.nil?)
		
		if not @mass_text.nil?
			@mass_text.each do |x|
				begin
					api.sms(x[0].phone, x[1]) if (not x[0].phone.nil?)
				rescue
					puts "Could not log into Google Voice"
				end
			end
		end

		if not @to_player.nil? and not @to_player.phone.nil? and not @to_player.phone.empty? and api
			begin
				api.sms(@to_player.phone, @message) if (not @to_player.phone.nil?)
			rescue
				puts "Could not log into Google Voice"
			end
		end
	end
end
