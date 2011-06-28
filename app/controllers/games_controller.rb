class GamesController < ApplicationController
	before_filter :check_admin, :only => ['new', 'create', 'edit', 'update']
  layout "expanded", :only => [:show]
  #layout "application", :exclude => [:show]

	def index
		@games = Game.all
	end

	def show
    if params[:id] == "current"
      @game = Game.current
    end

		@game ||= Game.find(params[:id])
    unless @logged_in_person.nil?
      @logged_in_registration_local = Registration.find_by_person_id_and_game_id(@logged_in_person, @game)
    end
	end

	def rules
		@game = Game.find(params[:id]) || @current_game
	end
	
  def new
		@game = Game.new
	end

	def edit
		@game = Game.find(params[:id])
		unless params[:game].nil?
			@game = Game.new(params[:game])
		end
	end

	def create
		@game = Game.new(params[:game])
		if Game.current.id.nil?
			@game.is_current = true
		end

		if @game.save()
			redirect_to :action => :index
		else
			flash[:message] = @game.errors.full_messages.first
			redirect_to :action => :new
		end
	end

	def update
		@game = Game.find(params[:id])
		if @game.update_attributes(params[:game])
			redirect_to :action => :edit
		else
			flash[:error] = @game.errors.full_messages.first
			render :action => :edit
		end
	end

end
