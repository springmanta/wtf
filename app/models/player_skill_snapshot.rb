class PlayerSkillSnapshot < ApplicationRecord
  belongs_to :player

  def skills
    Player::SKILLS.keys.index_with { |skill| public_send(skill) }
  end

  def overall_rating
    skills.values.sum.fdiv(Player::SKILLS.size).round(1)
  end
end
