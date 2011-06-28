class ApplicationController < ActionController::Base
	protect_from_forgery
	before_filter :setup
	
	def setup
		@current_game = Game.current
		
		# If they're logged in, we'll grab detect if they're an admin
		@logged_in = !(session[:cas_user].nil?)
		@logged_in_person = Person.find_or_create_by_caseid(session[:cas_user]) if @logged_in
		@is_admin ||= false
		if @logged_in
			@logged_in_registration = Registration.find_by_person_id_and_game_id(@logged_in_person,@current_game)
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
			return false
		else
			# Use automatic method to find the user if they exist in the database and
			#  create them otherwise.
			@logged_in_person = Person.find_or_create_by_caseid(session[:cas_user])
		end
		return true
	end
	def check_is_registered
		if check_login
			@logged_in_registration = Registration.find_by_person_id_and_game_id(@logged_in_person,@current_game)
			if @logged_in_registration.nil?
				flash[:error] = "You must register for the game before you can view this page."
				redirect_to root_url()
				return
			end
		end
	end
end
