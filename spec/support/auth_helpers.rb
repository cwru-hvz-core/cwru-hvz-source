module ControllerHelpers
  def log_in_as(user)
    controller.session[:cas_user] = user.caseid
  end
end
