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

ActiveRecord::Schema.define(:version => 20110126224603) do

  create_table "attendances", :force => true do |t|
    t.integer  "registration_id"
    t.integer  "mission_id"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feeds", :force => true do |t|
    t.integer  "registration_id"
    t.datetime "datetime"
    t.integer  "feeder_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "games", :force => true do |t|
    t.string   "short_name"
    t.datetime "registration_begins"
    t.datetime "registration_ends"
    t.datetime "game_begins"
    t.datetime "game_ends"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "infractions", :force => true do |t|
    t.integer  "registration_id"
    t.text     "reason"
    t.integer  "admin_id"
    t.integer  "severity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "missions", :force => true do |t|
    t.integer  "game_id"
    t.datetime "start"
    t.datetime "end"
    t.text     "description"
    t.integer  "winning_faction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.string   "name"
    t.string   "caseid"
    t.binary   "picture"
    t.string   "phone"
    t.datetime "last_login"
    t.boolean  "is_admin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "registrations", :force => true do |t|
    t.integer  "person_id"
    t.integer  "game_id"
    t.integer  "faction_id"
    t.string   "card_code"
    t.integer  "score"
    t.boolean  "is_oz"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.integer  "game_id"
    t.integer  "tagger_id"
    t.integer  "tagee_id"
    t.integer  "mission_id"
    t.datetime "datetime"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
