class PlayersController < ApplicationController
  before_action :set_player, only: %i[ show edit update destroy ]

  SORTABLE_COLUMNS = %w[name games goals overall].freeze

  def index
    @sort = SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "name"
    @direction = params[:direction] == "desc" ? "desc" : "asc"

    players = Player.alphabetical.includes(:appearances).with_attached_photo
    sorted = case @sort
    when "games" then players.sort_by(&:games_played)
    when "goals" then players.sort_by(&:goals_scored)
    when "overall" then players.sort_by(&:overall_rating)
    else players.sort_by { |player| player.name.downcase }
    end
    sorted.reverse! if @direction == "desc"
    @players = sorted
  end

  def show
  end

  def new
    @player = Player.new
  end

  def edit
  end

  def create
    @player = Player.new(player_params)

    if @player.save
      redirect_to @player, notice: "Player was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @player.update(player_params)
      redirect_to @player, notice: "Player was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @player.destroy!
    redirect_to players_path, notice: "Player was successfully deleted.", status: :see_other
  end

  def bulk_update
    player_ids = Array(params[:player_ids])

    if player_ids.empty?
      redirect_to players_path, alert: "Select at least one player first."
      return
    end

    active = ActiveModel::Type::Boolean.new.cast(params[:active])
    Player.where(id: player_ids).update_all(active: active, updated_at: Time.current)

    redirect_to players_path, notice: "#{player_ids.size} #{"player".pluralize(player_ids.size)} marked #{active ? "active" : "inactive"}."
  end

  private

  def set_player
    @player = Player.find(params[:id])
  end

  def player_params
    params.require(:player).permit(:name, :active, :photo, *Player::SKILLS.keys)
  end
end
