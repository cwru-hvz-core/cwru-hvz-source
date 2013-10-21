class MissionsController < ApplicationController
  before_filter :check_admin, :except => [ :show, :index ]

  def new
    @mission = Mission.new
  end

  def attendance
    @mission = Mission.find(params[:id], include: { game: { registrations: :person } })
    @game = @mission.game
  end

  def feeds
    @mission = Mission.find(params[:id], :include => [:feeds, {:attendances => :registration}])
    @feeds = @mission.feeds.includes(:registration => :person).sort_by(&:created_at).reverse
    @all_zombies = Set.new(Registration.where(:game_id => @current_game.id).
      includes(:game, :taggedby, :tagged, :feeds, :attendances, :person).
      select{ |x| x.is_zombie? || x.is_recently_deceased? })
    @present_zombies = @all_zombies & Set.new(@mission.attendances.map(&:registration))
    @need_feeding = (@all_zombies - Set.new(@feeds.map(&:registration))).
      sort_by{|x| [x.state_history[:deceased], x.score]}

    @feed = Feed.new({:mission => @mission})
  end

  def create
    @mission = Mission.new(params[:mission])
    @mission.game = @current_game
    if @mission.save
      redirect_to list_missions_path
    else
      flash[:error] = @mission.errors.full_messages.first
      redirect_to new_mission_path
    end
  end

  def index
    @missions = @current_game.missions.order(:start)
  end

  def show
    @mission = Mission.find(params[:id])
  end

  def list
    @missions = @current_game.missions.sort_by(&:start)
  end

  def edit
  @mission = Mission.find(params[:id])
  end

  def update
  @mission = Mission.find(params[:id])
  if @mission.update_attributes(params[:mission])
    redirect_to missions_url()
  else
    flash[:error] = "Could not save mission!"
    redirect_to root_url()
  end
  end

  def points
    @mission = Mission.find(params[:id], :include => {
      :attendances => { :registration => [:person, :game, :taggedby, :tagged, :feeds]}
    })
    @player_factions = Hash.new([]).merge(
      @mission.attendances.group_by { |a| a.registration.state_at(@mission.start) }
    )
  end

  def save_points
    @mission = Mission.find(params[:id], :include => {
      :attendances => { :registration => [:person, :game, :taggedby, :tagged, :feeds]}
    })

    @player_factions = Hash.new([]).merge(
      @mission.attendances.group_by { |a| a.registration.state_at(@mission.start) }
    )

    # If this is a mass assignment:
    if params[:mass_points].present?
      [ :human, :zombie, :deceased ].each do |faction|
        Attendance.
          where(:id => @player_factions[faction].map(&:id)).
          update_all(:score => params[:mass_points][faction].to_i)
      end
      return redirect_to points_mission_url(@mission)
    end

    # If this is an individual assignment:
    if params[:points].present?
      params[:points].each do |id, points|
        next if points.empty?
        Attendance.find(id).update_attribute(:score, points)
      end
      return redirect_to points_mission_url(@mission)
    end
  end
end
