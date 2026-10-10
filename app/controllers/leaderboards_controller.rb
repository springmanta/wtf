class LeaderboardsController < ApplicationController
  allow_unauthenticated_access

  LEADERBOARD_SIZE = 5

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
    @top_winners = ranked(players, :total_wins)
  end

  private

  def parse_month(value)
    return nil if value.blank?
    Date.strptime(value, "%Y-%m").beginning_of_month
  rescue ArgumentError
    nil
  end

  # Competition ranking, so equal values share a place and the next one skips
  # ahead (1, 1, 3) rather than reading as an arbitrary order between ties.
  def ranked(players, attribute)
    entries = players
      .map { |player| [ player, player.public_send(attribute).to_i ] }
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
