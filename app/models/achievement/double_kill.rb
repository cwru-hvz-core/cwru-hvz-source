class Achievement::DoubleKill < Achievement
  include AchievementRegistry

  class << self
    def on_player_tagged(tag)
      return if tag.tagger.has_achievement?(self)

      tag.tagger.tagged.order('datetime ASC').each_cons(2) do |first, second|
        if (second.datetime - first.datetime) < 30.minutes
          Achievement::DoubleKill.create(
            recipient: tag.tagger
          )
        end
      end
    end
  end
end
