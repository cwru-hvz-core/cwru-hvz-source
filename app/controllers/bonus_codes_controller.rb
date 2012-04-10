class BonusCodesController < ApplicationController
  before_filter :check_is_registered, :only => [:claim, :claim_submit]
  before_filter :check_admin, :only => [:new, :edit, :update, :create, :destroy]
  def new
    @code = BonusCode.new(params[:bonus_code])
  end

  def update
    @code = BonusCode.find(params[:id])
    if @code.nil?
      flash[:error] = "Could not find Bonus Code ID"
    else
      @registration = Registration.find_by_game_id_and_person_id(@current_game.id, params[:bonus_code][:person_id])
      if @registration.nil?
        flash[:error] = "Error: That person is not playing this game."
        redirect_to edit_bonus_code_url(@code)
        return
      end
      @code.attributes = params[:bonus_code]
      @code.registration = @registration
      @code.save()
    end
    redirect_to bonus_codes_url()
  end

  def create
    @code = BonusCode.new(params[:bonus_code])
    @code.code = @code.code.upcase
    @code.game = @current_game
    if @code.save()
      redirect_to bonus_codes_url()
      return
    else
      flash[:error] = @code.errors.full_messages.first
      render :new
    end
  end

  def index
    @codes = @current_game.bonus_codes
    if !@is_admin
      @codes = @codes.each{|x| x.registration_id.nil? and x.code = "??????"}.sort{|x,y| x.points <=> y.points}
    end
  end

  def show
  end

  def edit
    @code = BonusCode.find(params[:id])
    if @code.nil?
      flash[:error] = "Could not find Bonus Code ID"
      redirect_to bonus_codes_url()
    end
  end

  def destroy
    @code = BonusCode.find(params[:id])
    if @code.nil?
      flash[:error] = "Could not find Bonus Code ID"
    else
      @code.delete()
    end
    redirect_to bonus_codes_url()
  end

  def claim

  end

  def claim_submit
    if @is_admin
      @registration = Registration.find_by_game_id_and_person_id(@current_game.id, params[:person_id])
    else
      @registration = @logged_in_registration
    end
    if @registration.nil?
      flash[:error] = "Invalid Person For Current Game."
      redirect_to claim_bonus_code_url()
      return
    end
    @bonus_code = BonusCode.find_by_game_id_and_code(@current_game.id, params[:code_bonus].upcase)
    if @bonus_code.nil?
      flash[:error] = "Invalid Code!"
      redirect_to claim_bonus_code_url()
      return
    end
    # Valid code! Update and save.
    if @bonus_code.registration.nil?
      # Never before used code
      @bonus_code.registration = @registration
      if not @bonus_code.save()
        flash[:error] = "There was a problem registering this code. Please report this."
        redirect_to claim_bonus_code_url()
        return
      end
    else
      flash[:error] = "This code has already been used!"
      redirect_to claim_bonus_code_url()
      return
    end
    redirect_to bonus_codes_url()
  end

end
