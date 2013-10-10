module AchievementRegistry
  @achievements = []

  class << self
    def included(base)
      @achievements << base
    end

    def trigger(event, *args)
      @achievements.each do |a|
        method = "on_#{event}"
        a.send(method, *args) if a.respond_to?(method)
      end
    end

    # PubSubHub events:
    def handle_player_tagged(options)
      AchievementRegistry.trigger(:player_tagged, options[:tag])
    end
  end
end
