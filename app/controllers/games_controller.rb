class GamesController < ApplicationController
  before_filter :check_admin, :only => [:new, :create, :edit, :update, :emails, :admin_register, :admin_register_create, :heatmap, :index, :update_current]

  def index
    @games = Game.includes(:registrations).order(:game_begins).all
  end

  def show
    @game = Game.find(params[:id])
    check_admin unless @game.has_begun?
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
    @tags = Game.find(params[:id]).tags.sort_by { |x| x.latitude || 0 }
    if params[:tagger_id].present?
      @tags = @tags.select{|tag| tag.tagger_id == params[:tagger_id].to_i}
    end
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

  def update_current
    @game = Game.find(params[:active_game])
    @game.set_current

    redirect_to games_url
  end

  def emails
    @game = Game.find(params[:id])
    @registrations = @game.registrations
    if params[:faction_id].present?
      @registrations = @registrations.where(faction_id: params[:faction_id])
    end

    if params[:human_type].present?
      @registrations = @registrations.where(human_type: params[:human_type])
    end
  end

  def admin_register_new
    @game = Game.find(params[:id])
    @squads = @game.squads
  end

  def admin_register_create
    @game = Game.find(params[:id])
    @person = Person.where(:caseid => params[:person][:caseid]).first_or_initialize
    if @person.persisted?
      @person.update_attributes(:name => params[:person][:name], :phone => params[:person][:phone])
    end
    return redirect_to(admin_register_game_url(@game), :flash => { :error => 'You need to input a name for the person.' }) if !@person.name.present?
    return redirect_to(admin_register_game_url(@game), :flash => { :error => "Could not create or find person! #{@person.errors.full_messages.first}" }) if !@person.save

    @registration = Registration.where(:person_id => @person.id, :game_id => @game.id).first_or_initialize(
      :wants_oz => params[:registration][:wants_oz],
      :is_off_campus => params[:registration][:is_off_campus],
    )

    if @registration.persisted?
      flash[:error] = 'User is already registered for this game!'
      redirect_to admin_register_game_url(@game)
    else
      @registration.card_code = Registration.make_code
      @registration.score = 0

      if @registration.save(:validate => false)
        @registration.update_attribute(:squad_id, params[:registration][:squad_id]) if params[:registration][:squad_id].present?
      else
        flash[:error] = 'Could not register due to an error!'
        redirect_to admin_register_game_url(@game)
      end
    end

  end
end
