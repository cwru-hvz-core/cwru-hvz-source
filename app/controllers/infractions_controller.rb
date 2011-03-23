class InfractionsController < ApplicationController
	before_filter :check_admin, :only => [:new, :create, :destroy]
	before_filter :check_login, :only => [:show,:index]
	
	def index
		@registration = Registration.find(params[:registration_id], :include=>:infractions)
		if @is_admin || @registration.person_id == @person.id
			@infractions = @registration.infractions.sort{|x,y| x.created_at <=> y.created_at}
		else
			flash[:error] = "You do not have permission to view this person's infractions."
			redirect_to root_url
		end
	end

	def new
		if @is_admin
			@registration = Registration.find(params[:registration_id])
	  		@infraction = @registration.infractions.new
			@players = Registration.find_all_by_game_id(@current_game.id, :include => :person).sort{|x,y| x.person.name <=> y.person.name}
		else
			flash[:error] = "You do not have permission to report infractions! Use this form to contact the admins."
			redirect_to contact_messages_url
		end
	end

	def create
		@offender = Registration.find(params[:infraction][:registration_id])
		@infraction = @offender.infractions.new(params[:infraction])
		@infraction.admin_id = @logged_in_person.id
		unless @infraction.save()
			flash[:error] = @infraction.errors.full_messages.first
			redirect_to new_registration_infraction_url()
			return
		end
		@num_infractions = @offender.infractions.reject{|x| x.nullified}.length
	end

	def show
	end

	def edit
	end

	def update
	end

	def destroy
		if @is_admin
			@registration = Registration.find(params[:registration_id], :include=>:infractions)
			@infraction = @registration.infractions.find(params[:id])
			@infraction.nullified = true
                        @infraction.save(false)
			redirect_to registration_infractions_url(@registration)
		else
			flash[:error] = "You do not have permission to nullify infractions!"
			redirect_to root_url
		end
	end
end
