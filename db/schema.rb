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

ActiveRecord::Schema.define(version: 20170503142524) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "epds", force: :cascade do |t|
    t.integer  "id_radio"
    t.integer  "temperature"
    t.integer  "current"
    t.float    "voltage"
    t.float    "active_power"
    t.float    "reactive_power"
    t.float    "apparent_power"
    t.integer  "aggregated_active_energy"
    t.integer  "aggregated_reactive_energy"
    t.integer  "aggregated_apparent_energy"
    t.integer  "frequency"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "stat"
    t.integer  "dstat"
    t.integer  "nominal_power"
  end

end
