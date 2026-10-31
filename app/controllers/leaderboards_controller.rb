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
    @top_ratio = ranked(players) { |player| win_loss_ratio(player) }
  end

  private

  def parse_month(value)
    return nil if value.blank?
    Date.strptime(value, "%Y-%m").beginning_of_month
  rescue ArgumentError
    nil
  end

  # Undefined with zero losses (divide by zero) — treated as equal to the win
  # count, same convention as a kill/death ratio, so an unbeaten record still
  # sorts above a similar record that has lost at least once.
  def win_loss_ratio(player)
    wins = player.total_wins.to_i
    losses = player.total_losses.to_i
    (losses.zero? ? wins.to_f : wins.to_f / losses).round(2)
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
