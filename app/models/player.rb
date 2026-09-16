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

  def goals_scored
    appearances.sum(:goals)
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
