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

ActiveRecord::Schema.define(:version => 20121002143805) do

  create_table "attendances", :force => true do |t|
    t.integer   "registration_id"
    t.integer   "mission_id"
    t.integer   "score"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "bonus_codes", :force => true do |t|
    t.string    "code"
    t.integer   "points"
    t.integer   "game_id"
    t.integer   "registration_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "check_ins", :force => true do |t|
    t.integer   "registration_id"
    t.string    "hostname"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "contact_messages", :force => true do |t|
    t.string    "from"
    t.string    "regarding"
    t.text      "body"
    t.timestamp "occurred"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "game_id"
    t.boolean   "visible",    :default => true
    t.text      "note"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer   "priority",   :default => 0
    t.integer   "attempts",   :default => 0
    t.text      "handler"
    t.text      "last_error"
    t.timestamp "run_at"
    t.timestamp "locked_at"
    t.timestamp "failed_at"
    t.string    "locked_by"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "feeds", :force => true do |t|
    t.integer   "registration_id"
    t.timestamp "datetime"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "tag_id"
    t.integer   "mission_id"
  end

  create_table "games", :force => true do |t|
    t.string    "short_name"
    t.timestamp "registration_begins"
    t.timestamp "registration_ends"
    t.timestamp "game_begins"
    t.timestamp "game_ends"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "is_current"
    t.text      "information",                :default => "No information given."
    t.text      "rules",                      :default => "No rules have been posted yet. Check back later!"
    t.string    "time_zone",                  :default => "Eastern Time (US & Canada)"
    t.string    "gv_username"
    t.string    "gv_password"
    t.timestamp "oz_reveal"
    t.string    "phpbb_database_host"
    t.string    "phpbb_database_username"
    t.string    "phpbb_database_password"
    t.string    "phpbb_database"
    t.string    "phpbb_field_identification"
    t.integer   "phpbb_human_group"
    t.integer   "phpbb_zombie_group"
  end

  create_table "infractions", :force => true do |t|
    t.integer   "registration_id"
    t.text      "reason"
    t.integer   "admin_id"
    t.integer   "severity"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "nullified",       :default => false
  end

  create_table "missions", :force => true do |t|
    t.integer   "game_id"
    t.timestamp "start"
    t.timestamp "end"
    t.text      "description"
    t.integer   "winning_faction_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "title"
    t.text      "storyline"
  end

  create_table "people", :force => true do |t|
    t.string    "name"
    t.string    "caseid"
    t.binary    "picture"
    t.string    "phone"
    t.timestamp "last_login"
    t.boolean   "is_admin",   :default => false
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "registrations", :force => true do |t|
    t.integer   "person_id"
    t.integer   "game_id"
    t.integer   "faction_id"
    t.string    "card_code"
    t.integer   "score"
    t.boolean   "is_oz",         :default => false
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "wants_oz",      :default => false
    t.boolean   "is_off_campus", :default => false
    t.integer   "squad_id"
  end

  create_table "squads", :force => true do |t|
    t.string    "name"
    t.integer   "leader_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "game_id"
  end

  create_table "tags", :force => true do |t|
    t.integer   "game_id"
    t.integer   "tagger_id"
    t.integer   "tagee_id"
    t.integer   "mission_id"
    t.timestamp "datetime"
    t.integer   "score"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "admin_id"
  end

  create_table "waivers", :force => true do |t|
    t.integer   "person_id"
    t.integer   "game_id"
    t.integer   "studentid"
    t.date      "datesigned"
    t.date      "dateofbirth"
    t.string    "emergencyname"
    t.string    "emergencyrelationship"
    t.string    "emergencyphone"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

end
