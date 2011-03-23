class InfractionsController < ApplicationController
	before_filter :check_admin, :only => [:new, :create, :index]
	before_filter :check_login, :only => [:show]
	
	def index
	end

	def new
		if @is_admin
			@registration = Registration.find(params[:registration_id])
	  		@infraction = @registration.infractions.new
			@players = Registration.find_all_by_game_id(@current_game.id, :include => :person).sort{|x,y| x.person.name <=> y.person.name}
		end
	end

	def create
		@offender = Registration.find(params[:registration_id])
		@infraction = @offender.infractions.new(params[:infraction])
		@infraction.admin_id = @logged_in_person.id
		unless @infraction.save()
			flash[:error] = @infraction.errors.full_messages.first
			redirect_to new_registration_infraction_url()
			return
		end
		@num_infractions = @offender.infractions.length
		@total_severity = @offender.infractions.sum(:severity)
	end

	def show
	end

	def edit
	end

	def update
	end

	def destroy
	end
end
