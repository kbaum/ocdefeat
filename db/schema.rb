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

ActiveRecord::Schema.define(version: 20180517191451) do

  create_table "obsession_themes", force: :cascade do |t|
    t.integer "obsession_id"
    t.integer "theme_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "obsessions", force: :cascade do |t|
    t.text "intrusive_thought"
    t.text "triggers"
    t.integer "anxiety_rating"
    t.string "symptoms"
    t.text "rituals"
    t.integer "user_id"
    t.float "time_consumed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plans", force: :cascade do |t|
    t.string "title"
    t.string "goal"
    t.integer "obsession_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "steps", force: :cascade do |t|
    t.text "instructions"
    t.string "duration"
    t.integer "discomfort_degree"
    t.integer "plan_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "themes", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "severity"
    t.integer "role", default: 0
    t.string "role_requested"
    t.string "provider"
    t.string "variant"
  end

end
