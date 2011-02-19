#require 'googlevoiceapi'
require './config/private.rb'

class PeopleController < ApplicationController
	before_filter :check_login, :except => ["login", "logout", "update"]
	before_filter CASClient::Frameworks::Rails::Filter, :only => "login"

	# Note: On every page load where check_login is called as a before_filter,
	#  
	def index 

	end

	def edit
	
	end

	def update
		@person.update_attributes(params[:person])
		redirect_to(session[:was_at] || @person)
	end	


	def login
		# Define your Google username and password in config/private.rb
		api = GoogleVoice::Api.new($Google_Username, $Google_Password) unless $Google_Username.eql?("youremail@gmail.com")

		@person = Person.find_by_caseid(session[:cas_user])

		# TODO: Put this in its own controller, somewhere.
		if not @person.nil? and api
			begin
				api.sms(@person.phone, "Hello, you have just logged in!") if (not @person.phone.nil? and production?)
			rescue
				puts "Could not log into Google Voice"
			end
		end
		redirect_to (session[:was_at] or root_url())
	end
	def logout
		CASClient::Frameworks::Rails::Filter.logout(self)
		#redirect_to (session[:was_at] or root_url())
	end

end
