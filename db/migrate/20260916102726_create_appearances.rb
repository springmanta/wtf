class CreateAppearances < ActiveRecord::Migration[8.0]
  def change
    create_table :appearances do |t|
      t.references :game, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.string :team, null: false
      t.integer :goals, null: false, default: 0

      t.timestamps
    end

    add_index :appearances, [ :game_id, :player_id ], unique: true
  end
end
