class ApplicationController < ActionController::Base
	protect_from_forgery
	before_filter :setup
	
	def setup
		@current_game = Game.current
		
		# If they're logged in, we'll grab detect if they're an admin
		@logged_in = !(session[:cas_user].nil?)
		@is_admin ||= false
		if @logged_in
			@person = Person.find_by_caseid(session[:cas_user])
			@is_admin ||= @person.is_admin unless @person.nil?
		end
		# So we can disable some features (such as SMS notification)
		# during development.
		@is_production ||= (ENV['RAILS_ENV']=="production")
	end
	def check_admin
		self.check_login()
		redirect_to root_url() unless @is_admin
	end
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
				session[:was_at] ||= request.env['PATH_INFO']
				redirect_to edit_person_url(@person) unless (params[:controller] == 'people' and (params[:action]== 'edit' or params[:action] == "update"))
			end
		end
	end

end
