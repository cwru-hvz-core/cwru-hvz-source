class RegistrationsController < ApplicationController
	before_filter :check_admin, :only => [:index]
	before_filter :check_login, :only => [:new, :create]
	def new
		if @current_game.id.nil?
			flash[:error] = "Your administrators have not yet created a game to register for."
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
			redirect_to registration_url(@registration)
		else
			redirect_to new_registration_url()
		end
	end

	def destroy
	end

	def show
		@registration = Registration.find(params[:id])
	end

	def update
		r = Registration.find(params[:id])
		r.update_attributes(params[:registration])
		redirect_to edit_registration_url(params[:id])
	end

	def edit
		@registration = Registration.find(params[:id])
		@person = @registration.person;
	end

	def index
		@registrations = Registration.where(["registrations.game_id = ?",@current_game.id])
	end
end
