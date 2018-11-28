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

ActiveRecord::Schema.define(version: 2018_11_14_002059) do

  create_table "activity_streams_event_types", force: :cascade do |t|
    t.string "event_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "activity_streams_events", force: :cascade do |t|
    t.integer "event_type_id"
    t.string "object_id"
    t.string "object_type"
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["end_time"], name: "index_activity_streams_events_on_end_time"
  end

  create_table "resources", force: :cascade do |t|
    t.string "object_id"
    t.string "object_type"
    t.string "etag"
    t.datetime "object_last_update"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["object_id"], name: "index_resources_on_object_id", unique: true
  end

end
