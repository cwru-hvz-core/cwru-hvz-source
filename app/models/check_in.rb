class CheckIn < ActiveRecord::Base
  belongs_to :registration

  def self.get_location(hostname)
    nord = [/cse-xd\w+-\d+.\w+.(case|cwru).edu/, /cse-isr.engineering.(cwru|case).edu/]
    wade = [/benewah.stuaff.cwru.edu/, /minnehaha.stuaff.cwru.edu/, /antrim.stuaff.cwru.edu/, /lapeer.stuaff.cwru.edu/]
    nord.each do |n|
      if n.match(hostname.downcase)
        return "Nord"
      end
    end
    wade.each do |w|
      if w.match(hostname.downcase)
        return "Wade"
      end
    end
    return nil
  end

  def self.is_valid_place_and_time?(location, time)
    # Pass this the location (from get_location) and the current local time.
    # time must be from Time.now.utc + Game.current.utc_offset/1.hour
    # TODO: I think this will break if Game.current.utc_offset > 6 hours... but I'm not 100% sure.
    hour = time.hour# + (Game.current.utc_offset/1.hour)
    if location == "Wade"
      return true if hour < 6 or hour >= 18
    end
    if location == "Nord"
      return true if hour >=6 and hour < 18
    end
    return false
  end
end
