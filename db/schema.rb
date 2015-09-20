# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150920192518) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attendances", force: :cascade do |t|
    t.integer  "session_id",     null: false
    t.integer  "participant_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attendances", ["session_id", "participant_id"], name: "index_attendances_on_session_id_and_participant_id", unique: true, using: :btree

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
  end

  add_index "categories", ["name"], name: "index_categories_on_name", unique: true, using: :btree

  create_table "categorizations", force: :cascade do |t|
    t.integer  "category_id", null: false
    t.integer  "session_id",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categorizations", ["category_id", "session_id"], name: "index_categorizations_on_category_id_and_session_id", unique: true, using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "name",       null: false
    t.date     "date",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "levels", force: :cascade do |t|
    t.string "name"
  end

  create_table "participants", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.text     "bio"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "crypted_password"
    t.string   "persistence_token"
    t.string   "perishable_token",  default: "", null: false
  end

  add_index "participants", ["email"], name: "index_participants_on_email", unique: true, using: :btree
  add_index "participants", ["perishable_token"], name: "index_participants_on_perishable_token", using: :btree

  create_table "presentations", force: :cascade do |t|
    t.integer  "session_id"
    t.integer  "participant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "presenter_timeslot_restrictions", force: :cascade do |t|
    t.integer  "participant_id"
    t.integer  "timeslot_id"
    t.float    "weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "presenter_timeslot_restrictions", ["timeslot_id", "participant_id"], name: "present_timeslot_participant_unique", unique: true, using: :btree

  create_table "rooms", force: :cascade do |t|
    t.integer  "event_id",                   null: false
    t.string   "name",                       null: false
    t.integer  "capacity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "schedulable", default: true
  end

  create_table "sessions", force: :cascade do |t|
    t.integer  "participant_id",                 null: false
    t.string   "title",                          null: false
    t.text     "description",                    null: false
    t.boolean  "panel",          default: false, null: false
    t.boolean  "projector",      default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
    t.integer  "timeslot_id"
    t.integer  "room_id"
    t.string   "summary"
    t.integer  "level_id"
  end

  add_index "sessions", ["level_id"], name: "index_sessions_on_level_id", using: :btree

  create_table "settings", force: :cascade do |t|
    t.boolean "show_schedule"
    t.integer "current_event_id"
  end

  add_index "settings", ["current_event_id"], name: "index_settings_on_current_event_id", using: :btree

  create_table "timeslots", force: :cascade do |t|
    t.integer  "event_id",                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "schedulable", default: true
    t.string   "title"
  end

end
