class ApplicationController < ActionController::Base
  protect_from_forgery

  def check_login
  	if session[:cas_user].nil?
		session[:was_at] = request.env['PATH_INFO']
		redirect_to people_login_url()
	else
		# Use automatic method to find the user if they exist in the database and
		#  create them otherwise.
		@person = Person.find_or_create_by_caseid(session[:cas_user])
		if @person.name.nil?
			session[:needs_info] = true
			session[:was_at] = request.env['PATH_INFO']
			redirect_to edit_person_url(@person) unless (params[:controller] == 'people' and (params[:action]== 'edit' or params[:action] == "update"))
		end
	end
  end
end
