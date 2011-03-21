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

		if params[0].is_a?(Symbol)
			case params[0]
			when :tag then enqueue_tag_messages(params[1], params[2], params[3])
			end
		end
		if params[0].is_a?(Array)
			@mass_text = params[0]
		end
		if params[0].is_a?(Person) and params[1].is_a?(String)
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

	def enqueue_tag_messages(tag, feed1, feed2)
		messages = []
		@tagee = tag.tagee
		unless @tagee.nil?
			# If the tagged player is now a zombie, show then more pertinent information.
			states = @tagee.state_history
			if (states[:zombie] - @tagee.game.utc_offset) < Time.now
				msg = "You have officially been tagged and you're now a zombie! Wear your bandana around your head now, and tag humans! (You need a feed before " + states[:deceased].strftime("%A %I:%M %p") + ")"
			else
				msg = "You have officially been tagged. You become a zombie at " + states[:zombie].strftime("%I:%M %p") + " and have 48 hours from then to get a feed."
			end
			messages.push([@tagee.person, msg])
		end
		#@tagger = tag.tagger
		#unless @tagger.nil?
		#	messages.push([@tagger.person, "You have gotten a tag!" + @tagger.card_code])
		#end
		unless feed1.registration.nil?
			if tag.tagger.nil?
				# If it was an administrative kill...
				messages.push([feed1.registration.person, "You have been fed by an admin. You now need a feed before " + feed1.registration.state_history[:deceased].strftime("%A @ %I:%M %p") ])
			else 
				# If it was a normal kill...
				messages.push([feed1.registration.person, "You have been fed by " + tag.tagger.person.name + ". You now need a feed before " + feed1.registration.state_history[:deceased].strftime("%A @ %I:%M %p")])
			end
		end
		unless feed2.registration.nil?
			if tag.tagger.nil?
				# If it was an administrative kill...
				messages.push([feed2.registration.person, "You have been fed by an admin. You now need a feed before " + feed2.registration.state_history[:deceased].strftime("%A @ %I:%M %p") ])
			else 
				# If it was a normal kill...
				messages.push([feed2.registration.person, "You have been fed by " + tag.tagger.person.name + ". You now need a feed before " + feed2.registration.state_history[:deceased].strftime("%A @ %I:%M %p")])
			end
		end
		@mass_text = messages
	end
end
