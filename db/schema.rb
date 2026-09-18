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

ActiveRecord::Schema[8.0].define(version: 2026_09_18_125735) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "appearances", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "player_id", null: false
    t.string "team", null: false
    t.integer "goals", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "assists", default: 0, null: false
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

  create_table "player_skill_snapshots", force: :cascade do |t|
    t.integer "player_id", null: false
    t.integer "technique", null: false
    t.integer "passing", null: false
    t.integer "finishing", null: false
    t.integer "defense", null: false
    t.integer "positioning", null: false
    t.integer "pace", null: false
    t.integer "stamina", null: false
    t.integer "teamwork", null: false
    t.datetime "recorded_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id", "recorded_at"], name: "index_player_skill_snapshots_on_player_id_and_recorded_at"
    t.index ["player_id"], name: "index_player_skill_snapshots_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "technique", default: 5, null: false
    t.integer "passing", default: 5, null: false
    t.integer "finishing", default: 5, null: false
    t.integer "defense", default: 5, null: false
    t.integer "positioning", default: 5, null: false
    t.integer "pace", default: 5, null: false
    t.integer "stamina", default: 5, null: false
    t.integer "teamwork", default: 5, null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "appearances", "games"
  add_foreign_key "appearances", "players"
  add_foreign_key "player_skill_snapshots", "players"
  add_foreign_key "sessions", "users"
end
