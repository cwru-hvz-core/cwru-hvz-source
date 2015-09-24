module GamesHelper
  def scoreboard_highlight(text)
    "<span class='highlight'>#{h text}</span>".html_safe
  end

  def get_scoreboard_text(registration)
    cache_count   = registration.bonus_codes.length
    mission_count = registration.missions.length
    tag_count     = registration.tagged.length

    case registration.display_faction_id
    when Registration::HUMAN_FACTION
      survived_string = "Survived #{scoreboard_highlight((registration.display_time_survived / 1.hour).floor)} Hours"
      cache_string    = "#{scoreboard_highlight(cache_count)} #{cache_count == 1 ? 'cache' : 'caches'}" if cache_count > 0
      mission_string  = "#{scoreboard_highlight(mission_count)} #{mission_count == 1 ? 'mission' : 'missions'}" if mission_count > 0

      [survived_string, cache_string, mission_string].compact.join('+').html_safe
    when Registration::ZOMBIE_FACTION
      dies_in = (registration.time_until_death / 1.hour).ceil
      tag_string = "#{scoreboard_highlight(tag_count)} #{tag_count == 1 ? 'tag' : 'tags'}"
      

      [tag_string].join(' ').html_safe
    else
      'Deceased!'
    end
  end
end
