class Player < ApplicationRecord
  has_many :appearances, dependent: :destroy
  has_many :games, through: :appearances
  has_many :skill_snapshots, -> { order(:recorded_at) }, class_name: "PlayerSkillSnapshot", dependent: :destroy
  has_one_attached :photo

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

  ALLOWED_PHOTO_TYPES = %w[image/png image/jpeg image/webp].freeze
  MAX_PHOTO_SIZE = 10.megabytes

  validates :name, presence: true, uniqueness: true
  validate :photo_type_and_size, if: -> { photo.attached? }
  SKILLS.each_key do |skill|
    validates skill, numericality: { only_integer: true, in: 1..10 }
  end

  scope :active, -> { where(active: true) }
  scope :alphabetical, -> { order(:name) }
  # game_ids restricts which appearances count toward the totals (e.g. a single
  # month) without turning the join into a filter — a player with zero
  # appearances in that range still comes back with totals of 0 rather than
  # being dropped, which a WHERE on appearances would do.
  scope :with_appearance_totals, ->(game_ids: nil) {
    join_condition = "appearances.player_id = players.id"
    if game_ids
      ids = game_ids.map(&:to_i)
      ids = [ -1 ] if ids.empty?
      join_condition += " AND appearances.game_id IN (#{ids.join(',')})"
    end

    joins("LEFT OUTER JOIN appearances ON #{join_condition}")
      .joins("LEFT OUTER JOIN games ON games.id = appearances.game_id")
      .group(:id)
      .select(
        "players.*",
        "COALESCE(SUM(appearances.goals), 0) AS total_goals",
        "COALESCE(SUM(appearances.assists), 0) AS total_assists",
        "COUNT(appearances.id) AS total_appearances",
        "COALESCE(SUM(CASE
          WHEN appearances.team = 'team_one' AND games.team_one_score > games.team_two_score THEN 1
          WHEN appearances.team = 'team_two' AND games.team_two_score > games.team_one_score THEN 1
          ELSE 0
        END), 0) AS total_wins",
        "COALESCE(SUM(CASE
          WHEN appearances.team = 'team_one' AND games.team_one_score < games.team_two_score THEN 1
          WHEN appearances.team = 'team_two' AND games.team_two_score < games.team_one_score THEN 1
          ELSE 0
        END), 0) AS total_losses"
      )
  }

  def goals_scored
    appearances.sum(:goals)
  end

  def assists_recorded
    appearances.sum(:assists)
  end

  def games_played
    appearances.count
  end

  def record
    @record ||= appearances.each_with_object(Hash.new(0)) { |appearance, tally| tally[appearance.result] += 1 }
  end

  def wins
    record["win"]
  end

  def draws
    record["draw"]
  end

  def losses
    record["loss"]
  end

  def skills
    SKILLS.keys.index_with { |skill| public_send(skill) }
  end

  def overall_rating
    skills.values.sum.fdiv(SKILLS.size).round(1)
  end

  def record_skill_snapshot!
    skill_snapshots.create!(skills.merge(recorded_at: Time.current))
  end

  def initials
    name.split.map { |part| part[0] }.join.upcase.first(2)
  end

  private

  def photo_type_and_size
    unless ALLOWED_PHOTO_TYPES.include?(photo.content_type)
      errors.add(:photo, "must be a PNG, JPEG, or WebP image")
    end
    if photo.byte_size > MAX_PHOTO_SIZE
      errors.add(:photo, "must be smaller than #{MAX_PHOTO_SIZE / 1.megabyte}MB")
    end
  end
end
