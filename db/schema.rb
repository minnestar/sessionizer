# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100423214500) do

  create_table "attendances", :force => true do |t|
    t.integer  "session_id",     :null => false
    t.integer  "participant_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attendances", ["session_id", "participant_id"], :name => "index_attendances_on_session_id_and_participant_id", :unique => true

  create_table "categories", :force => true do |t|
    t.string "name", :null => false
  end

  add_index "categories", ["name"], :name => "index_categories_on_name", :unique => true

  create_table "categorizations", :force => true do |t|
    t.integer  "category_id", :null => false
    t.integer  "session_id",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categorizations", ["category_id", "session_id"], :name => "index_categorizations_on_category_id_and_session_id", :unique => true

  create_table "participants", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.integer  "participant_id",                    :null => false
    t.string   "title",                             :null => false
    t.text     "description",                       :null => false
    t.boolean  "panel",          :default => false, :null => false
    t.boolean  "projector",      :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
