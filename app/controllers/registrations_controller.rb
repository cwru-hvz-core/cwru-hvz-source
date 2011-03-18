class RegistrationsController < ApplicationController
	before_filter :check_admin, :only => [:index, :destroy]
	before_filter :check_login, :only => [:new, :create, :show]
	def new
		if @current_game.id.nil? or @current_game.registration_begins.nil? or @current_game.registration_ends.nil?
			flash[:error] = "Your administrators have not yet created a game to register for."
			redirect_to root_url()
			return
		end
		if (Time.now + @current_game.utc_offset) < @current_game.registration_begins
			flash[:error] = "Registration begins " + @current_game.dates[:registration_begins] + ". Please check back then!"
			redirect_to root_url()
		end
		if (Time.now + @current_game.utc_offset) > @current_game.registration_ends
			flash[:error] = "Registration ended " + @current_game.dates[:registration_ends] + ". If you would still like to play, please contact the administrators."
			redirect_to root_url()
		end
		@registration = Registration.find_or_initialize_by_person_id_and_game_id(@person.id, @current_game.id)
		if not @registration.card_code.nil?
			redirect_to registration_url(@registration)
		end
	end

	def create
		@registration = Registration.find_or_initialize_by_person_id_and_game_id(@person.id, @current_game.id)
		@registration.attributes = params[:registration]
		@registration.card_code = Registration.make_code
		@registration.score = 0
		if @registration.save()
			Delayed::Job.enqueue SendNotification.new(@person, "Thank you for registering for HvZ. Your card code is: " + @registration.card_code + ". Please keep this code on you at all times. Have fun!")
			redirect_to registration_url(@registration)
		else
			redirect_to new_registration_url()
		end
	end

	def destroy
		@registration = Registration.find(params[:id])
		@registration.delete() unless @registration.nil?
		redirect_to registrations_url()
	end

	def show
		@registration = Registration.find(params[:id])
		if @registration.person_id != @person.id
			flash[:error] = "This is not your registration!!"
			redirect_to root_url()
			return
		end
	end

	def update
		r = Registration.find(params[:id])
		r.update_attributes(params[:registration])
		redirect_to edit_registration_url(params[:id])
	end

	def edit
		@registration = Registration.find(params[:id])
		@person = @registration.person;
		if !@is_admin and @person != @logged_in_person
			flash[:error] = "You do not have permission to edit this registration."
			redirect_to root_url()
			return
		end
	end

	def index
		@registrations = Registration.find_all_by_game_id(@current_game.id, :include=>:person)

		@registrations_people = @registrations.map{|x| x.person_id}
		@allpeople = Person.all.map{|x| x if not @registrations_people.include?(x.id)}.compact
	end
end
