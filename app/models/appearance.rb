class Appearance < ApplicationRecord
  belongs_to :game
  belongs_to :player

  TEAMS = %w[team_one team_two].freeze

  validates :team, inclusion: { in: TEAMS }
  validates :goals, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :player_id, uniqueness: { scope: :game_id }

  def team_name
    game.public_send("#{team}_name")
  end

  def result
    own_score = game.public_send("#{team}_score")
    opponent_team = team == "team_one" ? "team_two" : "team_one"
    opponent_score = game.public_send("#{opponent_team}_score")

    if own_score > opponent_score
      "win"
    elsif own_score < opponent_score
      "loss"
    else
      "draw"
    end
  end
end
