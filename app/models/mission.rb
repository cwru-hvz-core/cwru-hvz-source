class Mission < ActiveRecord::Base
  belongs_to :game
  has_many :attendances
  has_many :feeds

  validates_presence_of :game_id, :title

  def validate
    if self.start < self.game.game_begins or self.end > self.game.game_ends
      self.errors.add_to_base("Mission's times are not between the game's begin and end times!")
    end
  end

  def times
    ftime = "%A, %B %e, %Y @ %I:%M %p"
    times = {
      :start => self.start.strftime(ftime),
      :end => self.end.strftime(ftime)
    }
  end

  def player_attending?(registration)
    @registration_ids ||= Set.new(attendances.pluck(:registration_id))

    @registration_ids.include?(registration.id)
  end
end
