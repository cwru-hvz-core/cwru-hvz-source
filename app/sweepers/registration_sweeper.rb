class RegistrationSweeper < ActionController::Caching::Sweeper
  observe Registration

  def after_save(record)
    expire_action(:controller => "api/game", :action => "players", :id => record.game.id)
  end
end
