class GamesController < ApplicationController
	before_filter :check_admin, :only => ['new', 'create', 'edit', 'update']

	def index
		@games = Game.all
	end

  def show
    @game = Game.find(params[:id])
    @players = @game.registrations.sort_by{ |x| -x.display_score }
    @ozs = @game.registrations.where(:is_oz => true).includes(:person)

    @graphdata = JSON.parse(
      Rails.cache.fetch("v1_games_#{@game.id}_show_graphdata", :expires_in => 1.minute) do
        @game.graph_data.to_json
      end
    )

    @squads = JSON.parse(
      Rails.cache.fetch("v1_games_#{@game.id}_show_squads", :expires_in => 1.minute) do
        @game.squads.includes({:registrations => :person}).
          select{|x| x.registrations.length >=2 }.
          sort_by(&:points).reverse.first(5).to_json(:methods => :points)
      end
    )
  end

	def rules
		@game = Game.find(params[:id]) || @current_game
	end

	def tree
		@game = Game.find(params[:id]) || @current_game

        if !@game.ozs_revealed?
          flash[:error] = "Original Zombies have not been revealed yet. No peeking at the tree!"
          redirect_to :root
        end
	end

  def heatmap
    @tags = @current_game.tags
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
