# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_09_29_151346) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attendances", id: :serial, force: :cascade do |t|
    t.integer "session_id", null: false
    t.integer "participant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id", "participant_id"], name: "index_attendances_on_session_id_and_participant_id", unique: true
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "categorizations", id: :serial, force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "session_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "session_id"], name: "index_categorizations_on_category_id_and_session_id", unique: true
  end

  create_table "code_of_conduct_agreements", force: :cascade do |t|
    t.bigint "participant_id", null: false
    t.bigint "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_code_of_conduct_agreements_on_event_id"
    t.index ["participant_id"], name: "index_code_of_conduct_agreements_on_participant_id"
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "levels", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "markdown_contents", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "markdown", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_markdown_contents_on_slug", unique: true
  end

  create_table "participants", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "email", limit: 255
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "crypted_password", limit: 255
    t.string "persistence_token", limit: 255
    t.string "perishable_token", limit: 255, default: "", null: false
    t.string "github_profile_username"
    t.string "github_og_image"
    t.string "github_og_url"
    t.string "twitter_handle"
    t.index ["email"], name: "index_participants_on_email", unique: true
    t.index ["perishable_token"], name: "index_participants_on_perishable_token"
  end

  create_table "presentations", id: :serial, force: :cascade do |t|
    t.integer "session_id"
    t.integer "participant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "presenter_timeslot_restrictions", id: :serial, force: :cascade do |t|
    t.integer "participant_id"
    t.integer "timeslot_id"
    t.float "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["timeslot_id", "participant_id"], name: "present_timeslot_participant_unique", unique: true
  end

  create_table "rooms", id: :serial, force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "name", limit: 255, null: false
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "schedulable", default: true
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.integer "participant_id", null: false
    t.string "title", limit: 255, null: false
    t.text "description", null: false
    t.boolean "panel", default: false, null: false
    t.boolean "projector", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "event_id"
    t.integer "timeslot_id"
    t.integer "room_id"
    t.string "summary", limit: 255
    t.integer "level_id"
    t.boolean "manually_scheduled", default: false, null: false
    t.integer "manual_attendance_estimate"
    t.index ["level_id"], name: "index_sessions_on_level_id"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.boolean "show_schedule"
    t.integer "current_event_id"
    t.boolean "allow_new_sessions", default: true, null: false
    t.index ["current_event_id"], name: "index_settings_on_current_event_id"
  end

  create_table "timeslots", id: :serial, force: :cascade do |t|
    t.integer "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean "schedulable", default: true
    t.string "title"
  end

end
