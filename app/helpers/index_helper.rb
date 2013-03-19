module IndexHelper
  def tag_text(tag)
    tagger = tag.tagger
    unless tagger.nil?
      tagger_str = tagger.person.name + " tagged "
      if tag.tagger.is_oz and not  @current_game.ozs_revealed?
        tagger_str = "An original zombie tagged "
      end
    end
    tagger_str ||= "An administrator converted "
    tagee = tag.tagee.person

    tagger_str + tagee.name + " " + distance_of_time_in_words(tag.datetime, Time.now) + " ago."
  end

  def checkin_text(checkin)
    begin
      person = checkin.registration.person
      place = CheckIn.get_location(checkin.hostname)
      checkin_str = person.name + " checked in at " + place + " " + distance_of_time_in_words(checkin.created_at, Game.now(Game.current)) + " ago."
    rescue
      checkin_str = "Someone checked in somewhere."
    end
    checkin_str
  end
end
