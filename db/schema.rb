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

ActiveRecord::Schema.define(version: 20180702012912) do

  create_table "comments", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "obsession_id"
    t.integer "user_id"
  end

  create_table "obsessions", force: :cascade do |t|
    t.string "intrusive_thought"
    t.string "triggers"
    t.integer "anxiety_rating"
    t.string "symptoms"
    t.string "rituals"
    t.integer "user_id"
    t.float "time_consumed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "theme_id"
  end

  create_table "patients", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "uid"
    t.string "provider"
    t.string "severity"
    t.string "variant"
    t.integer "therapist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plans", force: :cascade do |t|
    t.string "title"
    t.string "goal"
    t.integer "obsession_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "flooded", default: false
    t.boolean "finished", default: false
  end

  create_table "searches", force: :cascade do |t|
    t.string "key_terms"
    t.integer "user_id"
    t.integer "min_anxiety_rating"
    t.integer "max_anxiety_rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "min_time_consumed"
    t.float "max_time_consumed"
  end

  create_table "steps", force: :cascade do |t|
    t.text "instructions"
    t.string "duration"
    t.integer "discomfort_degree"
    t.integer "plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "completed", default: false
  end

  create_table "themes", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.integer "user_id"
  end

  create_table "treatments", force: :cascade do |t|
    t.string "treatment_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_treatments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "treatment_id"
    t.string "efficacy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "duration"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "uid"
    t.string "provider"
    t.string "role_requested"
    t.string "variant"
    t.string "severity"
    t.integer "role", default: 0
    t.integer "counselor_id"
    t.index ["counselor_id"], name: "index_users_on_counselor_id"
  end

end
