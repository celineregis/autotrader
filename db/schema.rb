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

ActiveRecord::Schema.define(version: 20160913142641) do

  create_table "bets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "odd_id"
    t.integer  "stake"
  end

  create_table "events", force: :cascade do |t|
    t.integer  "league_id"
    t.integer  "pp_event_id"
    t.string   "home"
    t.string   "away"
    t.datetime "event_start"
    t.integer  "home_goals"
    t.integer  "away_goals"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "is_live",        default: false
    t.integer  "playing_minute"
  end

  create_table "leagues", force: :cascade do |t|
    t.string   "name"
    t.string   "group"
    t.integer  "pp_league_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "odds", force: :cascade do |t|
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.float    "tipico_odd"
    t.float    "reference_odd"
    t.integer  "selection_id"
  end

  create_table "selections", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "pp_event_id"
    t.string   "market_name"
    t.string   "paramater"
    t.string   "choice_paramater"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

end
