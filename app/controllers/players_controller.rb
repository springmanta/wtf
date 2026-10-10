class PlayersController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :set_player, only: %i[ show edit update destroy toggle_active ]

  SORTABLE_COLUMNS = %w[name games goals assists overall].freeze

  def index
    @sort = SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "name"
    @direction = params[:direction] == "desc" ? "desc" : "asc"

    players = Player.alphabetical.includes(appearances: :game).with_attached_photo
    sorted = case @sort
    when "games" then players.sort_by(&:games_played)
    when "goals" then players.sort_by(&:goals_scored)
    when "assists" then players.sort_by(&:assists_recorded)
    when "overall" then players.sort_by(&:overall_rating)
    else players.sort_by { |player| player.name.downcase }
    end
    sorted.reverse! if @direction == "desc"
    @players = sorted
  end

  def show
    @back = back_link
  end

  def new
    @player = Player.new
  end

  def edit
  end

  def create
    @player = Player.new(player_params)

    if @player.save
      @player.record_skill_snapshot!
      redirect_to @player, notice: "Player was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @player.update(player_params)
      @player.record_skill_snapshot! if skills_changed?
      redirect_to @player, notice: "Player was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @player.destroy!
    redirect_to players_path, notice: "Player was successfully deleted.", status: :see_other
  end

  def toggle_active
    @player.update!(active: !@player.active)
    redirect_to players_path(sort: params[:sort], direction: params[:direction]),
      notice: "#{@player.name} marked #{@player.active? ? "active" : "inactive"}."
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
    @player = Player.includes(appearances: :game).find(params[:id])
  end

  # Players can be reached from several places (the roster, a game's pitch,
  # the leaderboard) — send "back" to wherever that was instead of always
  # defaulting to the players index.
  def back_link
    referer = same_origin_referer
    default = { path: players_path, label: "All players" }
    return default unless referer

    case referer.path
    when leaderboard_path
      { path: "#{leaderboard_path}#{"?#{referer.query}" if referer.query}", label: "Leaderboard" }
    when %r{\A/games/\d+\z}
      { path: referer.path, label: "Back to game" }
    else
      default
    end
  end

  def same_origin_referer
    return nil if request.referer.blank?
    uri = URI.parse(request.referer)
    uri if uri.host == request.host
  rescue URI::InvalidURIError
    nil
  end

  def skills_changed?
    (@player.saved_changes.keys.map(&:to_sym) & Player::SKILLS.keys).any?
  end

  def player_params
    params.require(:player).permit(:name, :active, :photo, *Player::SKILLS.keys)
  end
end
