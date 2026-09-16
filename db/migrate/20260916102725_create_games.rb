class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.date :played_on, null: false
      t.string :location
      t.text :notes
      t.string :team_one_name, null: false, default: "Light"
      t.string :team_two_name, null: false, default: "Dark"
      t.integer :team_one_score, null: false, default: 0
      t.integer :team_two_score, null: false, default: 0

      t.timestamps
    end
  end
end
