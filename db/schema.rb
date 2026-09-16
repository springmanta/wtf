# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_09_16_102726) do
  create_table "appearances", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "player_id", null: false
    t.string "team", null: false
    t.integer "goals", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "player_id"], name: "index_appearances_on_game_id_and_player_id", unique: true
    t.index ["game_id"], name: "index_appearances_on_game_id"
    t.index ["player_id"], name: "index_appearances_on_player_id"
  end

  create_table "games", force: :cascade do |t|
    t.date "played_on", null: false
    t.string "location"
    t.text "notes"
    t.string "team_one_name", default: "Light", null: false
    t.string "team_two_name", default: "Dark", null: false
    t.integer "team_one_score", default: 0, null: false
    t.integer "team_two_score", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "players", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "appearances", "games"
  add_foreign_key "appearances", "players"
end
