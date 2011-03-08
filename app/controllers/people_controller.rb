#require 'googlevoiceapi'
require './config/private.rb'

class PeopleController < ApplicationController
	before_filter :check_login, :except => ["login", "logout"]
	before_filter CASClient::Frameworks::Rails::Filter, :only => "login"

	# Note: On every page load where check_login is called as a before_filter 
	
	def update
		@person = Person.find(params[:id]) or Person.new
		if not @is_admin and @person != @logged_in_person
			flash[:error] = "You do not have permissions to edit this person's details."
			redirect_to root_url()
			return
		end
		@person.update_attributes(params[:person])

		if @is_admin and not params[:person][:is_admin].nil?
			# This has to be done separately because we need to ensure that the person granting
			# admin access is an admin themselves.
			@person.is_admin = params[:person][:is_admin]
			@person.save()
		end

		redirect_to(session[:was_at] || @person)
	end	
	
	def edit
		@toedit = Person.find(params[:id])
		if not @is_admin and @toedit != @logged_in_person
			flash[:error] = "You do not have permissions to edit this person's details."
			redirect_to root_url()
			return
		end
	end
	
	def show
		@person = Person.find(params[:id])
		if not @is_admin and @person != @logged_in_person
			flash[:error] = "You do not have permissions to view this person's profile."
			redirect_to root_url()
			return
		end
	end

	def list
		# TODO: Limit people to only the people who have registered on a certain site.
		@people = Person.all
	end
	
	def login
		redirect_to (session[:was_at] or root_url())
	end

	def logout
		CASClient::Frameworks::Rails::Filter.logout(self)
		#redirect_to (session[:was_at] or root_url())
	end

	def new
		redirect_to root_url()
	end
end
