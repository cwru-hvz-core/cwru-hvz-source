class PeopleController < ApplicationController
	before_filter :check_login, :except => ["login", "logout"]
	before_filter CASClient::Frameworks::Rails::Filter, :only => "login"

	# Note: On every page load where check_login is called as a before_filter,
	#  
	def index 

	end

	def edit
	
	end

	def update
		@person.update_attributes(params[:person])
		redirect_to(@person)
	end	


	def login
		redirect_to (session[:was_at] or root_url())
	end
	def logout
		CASClient::Frameworks::Rails::Filter.logout(self)
		#redirect_to (session[:was_at] or root_url())
	end

end
