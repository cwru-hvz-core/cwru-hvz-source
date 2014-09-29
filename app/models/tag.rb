class Tag < ActiveRecord::Base
  has_many :feeds
  belongs_to :game
  belongs_to :admin, :class_name => "Person", :foreign_key => "admin_id"
  belongs_to :tagger, :foreign_key => "tagger_id", :class_name => "Registration"
  belongs_to :tagee, :foreign_key => "tagee_id", :class_name => "Registration"

  validate :validate

  # TODO: Write code so additional feeds are scalable
  attr_accessor :tagee_card_code, :award_points, :feed_1, :feed_2

  after_create :trigger_player_tagged

  def tagee_card_code=(code)
    tagee = Registration.find_by_card_code(code.upcase)
    self.tagee_id = tagee.id unless tagee.nil?
  end

  def validate
    if self.tagger_id.nil?
      errors.add(:tagger_id, "cannot be empty!")
      return
    end
    if self.tagee_id.nil?
      errors.add(:tagee_id, "cannot be empty!")
      return
    end
    unless self.tagger_id == 0
      errors.add_to_base "Tagger " + self.tagger.inspect + " is not a zombie!" unless (self.tagger.is_zombie? or self.tagger.is_oz)
      # Check to ensure the tagger was a zombie at the time the player was tagged.
      if self.datetime < tagger.state_history[:zombie]
        errors.add_to_base "Tag occurred before the tagging player was a zombie!"
      end
    end
    tagee = Registration.find(self.tagee_id)
    errors.add_to_base "Tagged player is not a human!" unless tagee.is_human?
    errors.add_to_base "Tagged player is not playing this game!" unless tagee.game == self.game

    errors.add_to_base "Tag occurred before game started!" if self.datetime < self.game.game_begins
    errors.add_to_base "Tag occurs after game ends!" if self.datetime >= self.game.game_ends

    errors.add_to_base "Tag occurs in the future?!" if self.datetime >= Game.now(self.game)
  end

  def count_resulting_tags
    ary = self.num_resulting_tags
    (ary.flatten! or ary).sum
  end

  def num_resulting_tags
    tagged = self.tagee.tagged.map{|x| x.num_resulting_tags}
    if tagged.empty?
      return [1]
    else
      return tagged
    end
  end

private

  def trigger_player_tagged
    #PubSubHub.trigger(:player_tagged, tag: self)
  end
end
