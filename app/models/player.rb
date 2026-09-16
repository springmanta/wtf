class Player < ApplicationRecord
  has_many :appearances, dependent: :destroy
  has_many :games, through: :appearances

  SKILLS = {
    technique: "Technique",
    passing: "Passing",
    finishing: "Finishing",
    defense: "Defense",
    positioning: "Positioning",
    pace: "Pace",
    stamina: "Stamina",
    teamwork: "Teamwork"
  }.freeze

  validates :name, presence: true, uniqueness: true
  validates :photo_url, format: { with: %r{\Ahttps?://}i, message: "must be a URL starting with http:// or https://" }, allow_blank: true
  SKILLS.each_key do |skill|
    validates skill, numericality: { only_integer: true, in: 1..10 }
  end

  scope :active, -> { where(active: true) }
  scope :alphabetical, -> { order(:name) }

  def goals_scored
    appearances.sum(:goals)
  end

  def games_played
    appearances.count
  end

  def skills
    SKILLS.keys.index_with { |skill| public_send(skill) }
  end

  def overall_rating
    skills.values.sum.fdiv(SKILLS.size).round(1)
  end

  def initials
    name.split.map { |part| part[0] }.join.upcase.first(2)
  end
end
