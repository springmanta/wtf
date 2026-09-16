class Player < ApplicationRecord
  has_many :appearances, dependent: :destroy
  has_many :games, through: :appearances

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
  scope :alphabetical, -> { order(:name) }

  def goals_scored
    appearances.sum(:goals)
  end

  def games_played
    appearances.count
  end
end
