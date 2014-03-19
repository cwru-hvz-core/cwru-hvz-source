class Game < ActiveRecord::Base
  require './lib/game_validator.rb' # A better way??
  has_many :registrations
  has_many :tags
  has_many :missions
  has_many :waivers
  has_many :contact_messages
  has_many :squads
  has_many :ozs, :class_name => 'Registration', :conditions => ['is_oz = ?', true]
  has_many :bonus_codes
  validates_with GameValidator  # Defined in ./lib/game_validator.rb

  def self.current
    Game.find(:first, :conditions => ["is_current = ?", true]) or Game.new
  end

  def hours_to_starve
    48
  end

  def to_s(type)
    datetimeformat = '%A, %B %e, %Y @ %I:%M %p'

    case type
    when :date_range
      if game_ends.month == game_begins.month
        game_begins.strftime('%B %e') + ' - ' + game_ends.strftime('%e')
      else
        game_begins.strftime("%B %e") + ' - ' + game_ends.strftime('%B %e')
      end
    when :registration_begins
      registration_begins.strftime(datetimeformat)
    when :registration_ends
      registration_ends.strftime(datetimeformat)
    when :oz_reveal
      oz_reveal.strftime(datetimeformat)
    when :game_begins
      game_begins.strftime(datetimeformat)
    when :game_ends
      game_ends.strftime(datetimeformat)
    else
      super
    end
  end

  def zombietree_json
    # todo: destroy the next 3 lines with the fury of a thousand sons
    json = %&{id:"game#{id}",name:"#{short_name}",data:{},children:[&
    children = registrations(:include=>[:tagged,:person]).collect{|x| x.zombietree_json if((x.killing_tag.nil? or x.killing_tag.tagger.nil?) and not x.is_human?)}.compact
    json += %&#{ children.to_sentence(:last_word_connector => ",", :two_words_connector => ",", :words_connector => ",") unless children.empty?}]}&
  end

  def ongoing?
    return false unless game_begins.present? && game_ends.present?

    has_begun? and !has_ended?
  end

  def has_begun?
    Time.now >= game_begins
  end

  def has_ended?
    Time.now >= game_ends
  end

  def ozs_revealed?
    Time.now >= oz_reveal
  end

  def can_register?(person = nil)
    return false unless persisted?
    return false unless registration_begins.present? && registration_ends.present?
    return true if person.try(:is_admin)

    registration_begins < now && registration_ends > now
  end

  def now
    [Time.zone.now, game_ends].min
  end

  def self.now(game)
    game.now
  end

  def since_begin
    return 0 unless has_begun?
    Game.now(self) - game_begins
  end

  def mode_score
    UpdateGameState.points_for_time_survived((since_begin/1.hour).floor)
    #m = Registration.find_by_sql("SELECT *,COUNT(*) as scorect from registrations group by score order by scorect desc")
    #return 0 if m.nil?
    #m.first.score
  end

  def utc_offset
    dst_off = 0
    dst_off = 1.hour if Time.now.dst?
    ActiveSupport::TimeZone.new(time_zone).utc_offset + dst_off
  end

  def graph_data
    states = registrations.map{ |x| x.state_history }
    tslength = ((game_ends - game_begins) / 240).floor
    @data = {}
    240.times do |dt|
      now = game_begins + (dt.seconds.to_i*tslength)
      if now >= (Time.now + 48.hours)
        break
      end
      @data[now] = {:zombies => 0, :deceased => 0, :humans=>0}
      states.each do |s|
        # States is a hash of important times of players. Like
        # state = {:human => [time became human], :zombie => [time zombified],
        #          :deceased => [time of death]}
        # So, determining who is at which state is now pretty easy.
        if s[:human] <= now
          if s[:zombie] <= now
            if s[:deceased] <= now
              @data[now][:deceased] += 1
              next
            end
            @data[now][:zombies] += 1
            next
          end
          @data[now][:humans] += 1
        end
      end
    end
    @data = @data.sort.map do |x,y|
      [
        (x - game_begins) / 1.hour,
        y[:humans],
        # Certainty of the Human points:
        x < Time.now,
        y[:zombies],
        # Certainty of the Zombie points:
        x < Time.now,
        y[:deceased],
        # Certainty of the Deceased points:
        x < Time.now,
      ]
    end
  end

  def set_current
   if update_attribute(:is_current, true)
     Game.where('is_current = ? AND id <> ?', true, id).each do |g|
       g.update_attribute(:is_current, false)
     end
   end
  end
end

