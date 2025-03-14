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

ActiveRecord::Schema[7.1].define(version: 2025_03_13_020004) do
  create_schema "heroku_ext"

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "attendances", id: :serial, force: :cascade do |t|
    t.integer "session_id", null: false
    t.integer "participant_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["session_id", "participant_id"], name: "index_attendances_on_session_id_and_participant_id", unique: true
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "categorizations", id: :serial, force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "session_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["category_id", "session_id"], name: "index_categorizations_on_category_id_and_session_id", unique: true
  end

  create_table "code_of_conduct_agreements", force: :cascade do |t|
    t.bigint "participant_id", null: false
    t.bigint "event_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["event_id"], name: "index_code_of_conduct_agreements_on_event_id"
    t.index ["participant_id"], name: "index_code_of_conduct_agreements_on_participant_id"
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.date "date", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "levels", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "markdown_contents", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "markdown", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["slug"], name: "index_markdown_contents_on_slug", unique: true
  end

  create_table "participants", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "email", limit: 255, null: false
    t.text "bio"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "crypted_password", limit: 255, null: false
    t.string "persistence_token", limit: 255
    t.string "perishable_token", limit: 255, default: "", null: false
    t.datetime "email_confirmed_at", precision: nil
    t.index ["email"], name: "index_participants_on_email", unique: true
    t.index ["perishable_token"], name: "index_participants_on_perishable_token"
  end

  create_table "presentations", id: :serial, force: :cascade do |t|
    t.integer "session_id"
    t.integer "participant_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "presenter_timeslot_restrictions", id: :serial, force: :cascade do |t|
    t.integer "participant_id"
    t.integer "timeslot_id"
    t.float "weight"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["timeslot_id", "participant_id"], name: "present_timeslot_participant_unique", unique: true
  end

  create_table "rooms", id: :serial, force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "name", limit: 255, null: false
    t.integer "capacity"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "schedulable", default: true
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.integer "participant_id", null: false
    t.string "title", limit: 255, null: false
    t.text "description", null: false
    t.boolean "panel", default: false, null: false
    t.boolean "projector", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "starts_at", precision: nil
    t.datetime "ends_at", precision: nil
    t.boolean "schedulable", default: true
    t.string "title"
  end

end
