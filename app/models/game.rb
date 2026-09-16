class Game < ApplicationRecord
  has_many :appearances, dependent: :destroy
  has_many :players, through: :appearances

  accepts_nested_attributes_for :appearances, allow_destroy: true,
    reject_if: proc { |attrs| attrs["team"].blank? }

  validates :played_on, presence: true
  validates :team_one_name, presence: true
  validates :team_two_name, presence: true
  validates :team_one_score, :team_two_score,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :recent_first, -> { order(played_on: :desc, id: :desc) }

  def team_one_appearances
    appearances.select { |a| a.team == "team_one" }
  end

  def team_two_appearances
    appearances.select { |a| a.team == "team_two" }
  end

  def result_summary
    if team_one_score > team_two_score
      "#{team_one_name} win"
    elsif team_two_score > team_one_score
      "#{team_two_name} win"
    else
      "Draw"
    end
  end
end
