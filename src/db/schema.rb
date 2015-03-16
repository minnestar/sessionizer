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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130304053929) do

  create_table "attendances", :force => true do |t|
    t.integer  "session_id",     :null => false
    t.integer  "participant_id", :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "attendances", ["session_id", "participant_id"], :name => "index_attendances_on_session_id_and_participant_id", :unique => true

  create_table "categories", :force => true do |t|
    t.string "name", :null => false
  end

  add_index "categories", ["name"], :name => "index_categories_on_name", :unique => true

  create_table "categorizations", :force => true do |t|
    t.integer  "category_id", :null => false
    t.integer  "session_id",  :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "categorizations", ["category_id", "session_id"], :name => "index_categorizations_on_category_id_and_session_id", :unique => true

  create_table "events", :force => true do |t|
    t.string   "name",       :null => false
    t.date     "date",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "levels", :force => true do |t|
    t.string "name"
  end

  create_table "participants", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.text     "bio"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "crypted_password"
    t.string   "persistence_token"
  end

  add_index "participants", ["email"], :name => "index_participants_on_email", :unique => true

  create_table "presentations", :force => true do |t|
    t.integer  "session_id"
    t.integer  "participant_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "presenter_timeslot_restrictions", :force => true do |t|
    t.integer  "participant_id"
    t.integer  "timeslot_id"
    t.float    "weight"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "presenter_timeslot_restrictions", ["timeslot_id", "participant_id"], :name => "present_timeslot_participant_unique", :unique => true

  create_table "rooms", :force => true do |t|
    t.integer  "event_id",   :null => false
    t.string   "name",       :null => false
    t.integer  "capacity"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sessions", :force => true do |t|
    t.integer  "participant_id",                    :null => false
    t.string   "title",                             :null => false
    t.text     "description",                       :null => false
    t.boolean  "panel",          :default => false, :null => false
    t.boolean  "projector",      :default => false, :null => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "event_id"
    t.integer  "timeslot_id"
    t.integer  "room_id"
    t.string   "summary"
    t.integer  "level_id"
  end

  add_index "sessions", ["level_id"], :name => "index_sessions_on_level_id"

  create_table "timeslots", :force => true do |t|
    t.integer  "event_id",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.datetime "starts_at"
    t.datetime "ends_at"
  end

end
