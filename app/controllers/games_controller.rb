class GamesController < ApplicationController
	before_filter :check_admin, :only => ['new', 'create', 'edit', 'update']
	before_filter :get_graph_data, :only => ['show', 'graphdata']
  layout "expanded", :only => [:show]

	def index
		@games = Game.all
	end

	def show
	
	end

	def graphdata
		respond_to do |format|
			format.csv
		end
	end
	def rules
		@game = Game.find(params[:id]) || @current_game
	end
	def tree
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

	def get_graph_data
		@game = Game.find(params[:id], :include=>:tags)
    @players = Registration.find_all_by_game_id(@game, :include=>[:person,:taggedby,:missions,:infractions,:bonus_codes])
    if params[:sorttype] == "deceased"
		  @players = @players.sort_by{ |x| [x.state_history[:deceased], -x.display_score, x.person.name] }
    else
		  @players = @players.sort_by{ |x| [-x.display_score, x.person.name] }
    end

		@ozs = @players.map{ |x| x if x.is_oz }.compact
		
		
	end
end
