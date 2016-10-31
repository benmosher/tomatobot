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

ActiveRecord::Schema.define(version: 20161031173922) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "tasks", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "user_id"
    t.text     "completed"
    t.text     "distraction"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "tasks", ["team_id"], name: "index_tasks_on_team_id", using: :btree
  add_index "tasks", ["user_id"], name: "index_tasks_on_user_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "slack_team_id"
    t.string   "access_token"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "slack_id"
    t.string   "name"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "slack_token"
    t.string   "url_key"
    t.string   "timezone"
    t.boolean  "dnd_mode",    default: false
    t.integer  "duration",    default: 25
  end

  add_index "users", ["slack_id"], name: "index_users_on_slack_id", unique: true, using: :btree

  add_foreign_key "tasks", "teams"
  add_foreign_key "tasks", "users"
end
