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
    Twilio.connect(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])

    if @mass_text
      @mass_text.each do |x|
        Twilio::Sms.message(ENV['TWILIO_PHONE_NUMBER'], x[0].phone, x[1]) if x[0].phone.present?
      end
    end

    if @to_player && @to_player.phone.present?
      Twilio::Sms.message(ENV['TWILIO_PHONE_NUMBER'], @to_player.phone, @message)
    end
  end

  def enqueue_tag_messages(tag, feed1, feed2)
    messages = []
    @tagee = tag.tagee
    unless @tagee.nil?
      # If the tagged player is now a zombie, show then more pertinent information.
      states = @tagee.state_history
      if states[:zombie] < Time.now
        msg = "You have officially been tagged and you're now a zombie! Wear your bandana around your head now, and tag humans! (You need a feed before " + states[:deceased].strftime("%A %I:%M %p") + ")"
      else
        msg = "You have officially been tagged. You become a zombie at " + states[:zombie].strftime("%I:%M %p") + " and have 48 hours from then to get a feed."
      end
      messages.push([@tagee.person, msg])
    end

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
