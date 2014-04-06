#TODO: This file should contain the logic to, at any point,
# determine based on the database state, precisely who is
# human, zombie, and deceased. This script should also calculate
# point totals.
#
# Note: This file is responsible for being the correct
# judge of the current state. This file should update the following
# 'caches' of the current state -- so it can be easily
# accessed elsewhere:
#   registration.faction_id
#   registration.score
#
# Also, this file should store the current game state in the database
# if it has changed -- so all changes can be tracked over time.
class UpdateGameState
  def initialize
    @current_game = Game.current
  end

  def perform
    Time.zone = @current_game.time_zone

    @players = @current_game.registrations.includes(:person)

    @human_faction = @players.select(&:is_human?)

    @zombie_faction = @players.select(&:is_zombie?)

    @deceased_faction = @players.select(&:is_deceased?)

    @players.collect {|x| x.score = 0} # Reset the scores
    calculate_mission_scores(@players)
    calculate_human_scores(@players)
    calculate_zombie_tag_scores(@zombie_faction)
    calculate_cache_scores(@players)

    factions = {
      :human => @human_faction,
      :zombie => @zombie_faction,
      :deceased => @deceased_faction
    }

    update_faction_cache(factions)

    update_forums(factions)


    # We have to override validation because the registrations are generally not changable
    # after registration ends.
    [@human_faction, @zombie_faction, @deceased_faction].flatten.each { |x| x.save(:validate => false) }
    @current_game.touch
    Delayed::Job.enqueue(UpdateGameState.new(),{ :run_at => Time.now + 1.minute })
  end

  def update_forums(factions)
    params = {}
    params[:human] = factions[:human].map { |r| r.person.caseid }.join(',')
    params[:zombie] = factions[:zombie].map { |r| r.person.caseid }.join(',')
    params[:core] = Person.where(is_admin: true).pluck(:caseid).join(',')

    uri = URI.parse('http://forum.casehvz.com/hvz/groups')
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(params.merge(api_key: 'fa7eb9f91ac0dee653d991f9b44f72f8f05421a157b00369162aa978d30d56a4'))

    http.request(request)
  end

  def update_faction_cache(factions)
    factions[:human].each do |h|
      h.faction_id = 0
    end

    factions[:zombie].each do |h|
      if h.faction_id == 0
        h.human_type = nil
        Delayed::Job.enqueue SendNotification.new(h.person,
          "Welcome to the horde. Wear your headband with pride! Zombie Chant: What do we want? Brains! When do we want it? Brains!")
      end
      if h.faction_id == 2
        Delayed::Job.enqueue SendNotification.new(h.person,
          "Due to an error in the site, you were mistakenly marked as \"deceased\"." +
          "You are no longer deceased and should continue playing as a zombie until further notice. Sorry!")
      end

      h.faction_id = 1
    end

    factions[:deceased].each do |h|
      if h.faction_id == 1
        Delayed::Job.enqueue SendNotification.new(h.person,
          "Sorry, but your status has become \"deceased\". You are now out of the" + 
          "game until the Final Mission. If this is a mistake (e.g. because of a mission)," +
          "it should be fixed shortly. Otherwise, we'll see you at the final mission!")
      end

      h.faction_id = 2
    end
  end

  def calculate_human_scores(all_players)
    # This is where any fancy math would go to determine the score of someone
    all_players.each do |h|
      h.score += UpdateGameState.points_for_time_survived((h.time_survived / 1.hour).floor)
    end
  end

  def calculate_cache_scores(all_players)
    all_players.each do |h|
      h.score += h.bonus_codes.sum(:points)
    end
  end

  def calculate_mission_scores(all_players)
    all_players.each do |h|
      h.score += h.missions.sum(:score)
    end
  end

  def self.points_for_time_survived(hours)
    1200 + 50 * hours
  end

  def calculate_zombie_tag_scores(zombie)
    zombie.each do |z|
      z.tagged.each do |t|
        z.score += t.score
      end
    end
  end
end
