class LeaderboardsController < ApplicationController
  allow_unauthenticated_access

  LEADERBOARD_SIZE = 5

  # A player must average at least this many appearances per month (across
  # the months in view) to qualify for the MVP ranking — otherwise one big
  # game could rank someone who barely shows up above a regular.
  MIN_APPEARANCES_PER_MONTH = 2

  def show
    @available_months = Game.order(played_on: :desc).pluck(:played_on).map(&:beginning_of_month).uniq
    @selected_month = parse_month(params[:month])

    games_in_range = @selected_month ? Game.where(played_on: @selected_month.all_month) : Game.all
    @total_games = games_in_range.count

    players = Player.with_appearance_totals(game_ids: @selected_month && games_in_range.ids)
      .with_attached_photo.to_a

    @top_scorers = ranked(players, :total_goals)
    @top_assisters = ranked(players, :total_assists)
    @most_present = ranked(players, :total_appearances)
    @top_mvp = ranked(mvp_eligible(players)) { |player| mvp_score(player) }
  end

  private

  def parse_month(value)
    return nil if value.blank?
    Date.strptime(value, "%Y-%m").beginning_of_month
  rescue ArgumentError
    nil
  end

  # "Per month" is averaged over one month when a specific month is
  # selected, or over every month on record for "All time".
  def mvp_eligible(players)
    qualifying_months = @selected_month ? 1 : @available_months.size
    return [] if qualifying_months.zero?

    players.select { |player| player.total_appearances.to_f / qualifying_months >= MIN_APPEARANCES_PER_MONTH }
  end

  # 2 x (goals + assists)/appearances + 1.5 x wins/appearances — rewards
  # attacking output and winning per game played, so it reads as a rate of
  # contribution rather than raw totals, with assiduity already factored in
  # via the appearances denominator (and the MIN_APPEARANCES_PER_MONTH gate
  # above, which keeps one big game from skewing the rate).
  def mvp_score(player)
    appearances = player.total_appearances.to_i
    return 0.0 if appearances.zero?

    goals = player.total_goals.to_i
    assists = player.total_assists.to_i
    wins = player.total_wins.to_i

    (2 * (goals + assists).fdiv(appearances) + 1.5 * wins.fdiv(appearances)).round(2)
  end

  # Competition ranking, so equal values share a place and the next one skips
  # ahead (1, 1, 3) rather than reading as an arbitrary order between ties.
  # Pass either an attribute name or a block computing the value per player.
  def ranked(players, attribute = nil, &value_for)
    value_for ||= ->(player) { player.public_send(attribute).to_i }

    entries = players
      .map { |player| [ player, value_for.call(player) ] }
      .reject { |_player, value| value.zero? }
      .sort_by { |player, value| [ -value, player.name.downcase ] }
      .first(LEADERBOARD_SIZE)

    rank = 0
    previous_value = nil

    entries.each_with_index.map do |(player, value), index|
      rank = index + 1 unless value == previous_value
      previous_value = value
      { rank: rank, player: player, value: value }
    end
  end
end
