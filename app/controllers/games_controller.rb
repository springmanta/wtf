class GamesController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :set_game, only: %i[show edit update destroy]
  before_action :load_player_balance_stats, only: %i[new edit create update]

  def index
    @games = Game.recent_first.includes(appearances: :player)
  end

  def show
  end

  def new
    @game = Game.new(played_on: Date.current, team_one_name: "Light", team_two_name: "Dark")
    build_blank_appearances(@game)
  end

  def edit
    existing_player_ids = @game.appearances.map(&:player_id)
    Player.active.alphabetical.with_attached_photo.where.not(id: existing_player_ids).each do |player|
      @game.appearances.build(player: player)
    end
  end

  def create
    @game = Game.new(game_params)

    if @game.save
      redirect_to @game, notice: "Game was successfully recorded."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @game.update(game_params)
      redirect_to @game, notice: "Game was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @game.destroy!
    redirect_to games_path, notice: "Game was successfully deleted.", status: :see_other
  end

  private

  def set_game
    @game = Game.includes(appearances: { player: { photo_attachment: :blob } }).find(params[:id])
  end

  def build_blank_appearances(game)
    Player.active.alphabetical.with_attached_photo.each do |player|
      game.appearances.build(player: player)
    end
  end

  # Lifetime output rate (not just the current game) — used by the
  # WTF Randomize button to balance teams alongside each player's skill
  # rating. Goals+assists per appearance, not raw totals, so a player with
  # one big game doesn't read as a bigger threat than a consistent scorer.
  def load_player_balance_stats
    @player_balance_stats = Player.with_appearance_totals.each_with_object({}) do |player, stats|
      appearances = player.total_appearances.to_i
      output_rate = appearances.zero? ? 0.0 : (player.total_goals.to_i + player.total_assists.to_i).fdiv(appearances)
      stats[player.id] = { overall: player.overall_rating, output_rate: output_rate.round(2) }
    end
  end

  def game_params
    params.require(:game).permit(
      :played_on, :location, :notes,
      :team_one_name, :team_two_name, :team_one_score, :team_two_score,
      appearances_attributes: [ :id, :player_id, :team, :goals, :assists, :_destroy ]
    )
  end
end
