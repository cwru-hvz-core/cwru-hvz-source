class AchievementManager
  def self.handle_player_tagged(options)
    AchievementRegistry.trigger(:player_tagged, options[:tag])
  end
end

module AchievementRegistry
  @achievements = []

  class << self
    def included(base)
      @achievements << base
    end

    def trigger(event, *args)
      @achievements.each do |a|
        a.send("on_#{event}", *args)
      end
    end
  end
end

class Achievement < ActiveRecord::Base
end

class AchievementDoubleKill
  include AchievementRegistry

  class << self
    def on_player_tagged(tag)
    end
  end
end
