# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_10_190307) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "attendances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "event_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["event_id"], name: "index_attendances_on_event_id"
    t.index ["user_id", "event_id"], name: "index_attendances_on_user_id_and_event_id", unique: true
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "auction_items", default: false
    t.string "city"
    t.boolean "countdown_timer", default: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.text "description"
    t.integer "dress_code"
    t.time "end_time"
    t.boolean "gift_items", default: false
    t.string "hashtags", default: [], array: true
    t.uuid "organization_id", null: false
    t.time "start_time"
    t.decimal "starting_ticket_price", precision: 10, scale: 2
    t.string "state"
    t.integer "status", default: 0, null: false
    t.string "street_address"
    t.string "ticket_link"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "venue_name"
    t.string "zip"
    t.index ["hashtags"], name: "index_events_on_hashtags", using: :gin
    t.index ["organization_id"], name: "index_events_on_organization_id"
  end

  create_table "follows", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "organization_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["organization_id"], name: "index_follows_on_organization_id"
    t.index ["user_id", "organization_id"], name: "index_follows_on_user_id_and_organization_id", unique: true
    t.index ["user_id"], name: "index_follows_on_user_id"
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "causes", default: [], array: true
    t.datetime "created_at", null: false
    t.text "description"
    t.string "donation_url"
    t.string "email", null: false
    t.string "industries", default: [], array: true
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "phone"
    t.string "primary_cause"
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["causes"], name: "index_organizations_on_causes", using: :gin
    t.index ["email"], name: "index_organizations_on_email", unique: true
    t.index ["industries"], name: "index_organizations_on_industries", using: :gin
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "bio"
    t.date "birthdate"
    t.string "city"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "interested_causes", default: [], array: true
    t.string "interested_industries", default: [], array: true
    t.string "last_name", null: false
    t.string "password_digest", null: false
    t.string "sex"
    t.string "social_facebook"
    t.string "social_instagram"
    t.string "social_linkedin"
    t.string "social_x"
    t.string "state"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.boolean "visibility", default: true
    t.boolean "visibility_email", default: false
    t.boolean "visibility_full_name", default: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["interested_causes"], name: "index_users_on_interested_causes", using: :gin
    t.index ["interested_industries"], name: "index_users_on_interested_industries", using: :gin
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "attendances", "events"
  add_foreign_key "attendances", "users"
  add_foreign_key "events", "organizations"
  add_foreign_key "follows", "organizations"
  add_foreign_key "follows", "users"
end
