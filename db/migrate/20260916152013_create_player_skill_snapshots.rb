class CreatePlayerSkillSnapshots < ActiveRecord::Migration[8.0]
  def up
    create_table :player_skill_snapshots do |t|
      t.references :player, null: false, foreign_key: true
      t.integer :technique, null: false
      t.integer :passing, null: false
      t.integer :finishing, null: false
      t.integer :defense, null: false
      t.integer :positioning, null: false
      t.integer :pace, null: false
      t.integer :stamina, null: false
      t.integer :teamwork, null: false
      t.datetime :recorded_at, null: false

      t.timestamps
    end

    add_index :player_skill_snapshots, [ :player_id, :recorded_at ]

    # Baseline snapshot for players that already existed before this feature,
    # so their progression chart isn't empty the first time it's viewed.
    execute <<~SQL
      INSERT INTO player_skill_snapshots
        (player_id, technique, passing, finishing, defense, positioning, pace, stamina, teamwork, recorded_at, created_at, updated_at)
      SELECT id, technique, passing, finishing, defense, positioning, pace, stamina, teamwork, updated_at, updated_at, updated_at
      FROM players
    SQL
  end

  def down
    drop_table :player_skill_snapshots
  end
end
