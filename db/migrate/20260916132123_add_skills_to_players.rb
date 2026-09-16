class AddSkillsToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :photo_url, :string
    add_column :players, :technique, :integer, null: false, default: 5
    add_column :players, :passing, :integer, null: false, default: 5
    add_column :players, :finishing, :integer, null: false, default: 5
    add_column :players, :defense, :integer, null: false, default: 5
    add_column :players, :positioning, :integer, null: false, default: 5
    add_column :players, :pace, :integer, null: false, default: 5
    add_column :players, :stamina, :integer, null: false, default: 5
    add_column :players, :teamwork, :integer, null: false, default: 5
  end
end
