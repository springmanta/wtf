module ApplicationHelper
  RANK_MEDALS = { 1 => "🥇", 2 => "🥈", 3 => "🥉" }.freeze

  def rank_badge(rank)
    RANK_MEDALS.fetch(rank, rank.to_s)
  end
end
