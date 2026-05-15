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

ActiveRecord::Schema[8.1].define(version: 2026_05_15_142447) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "attachments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "file_size"
    t.string "file_type"
    t.string "file_url"
    t.bigint "note_id", null: false
    t.datetime "updated_at", null: false
    t.index ["note_id"], name: "index_attachments_on_note_id"
  end

  create_table "notes", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.boolean "important"
    t.bigint "patient_id", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["patient_id"], name: "index_notes_on_patient_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "patients", force: :cascade do |t|
    t.integer "age"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "pathology"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_patients_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role"
    t.string "sector"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vocabularies", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.string "input"
    t.string "output"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_vocabularies_on_user_id"
  end

  add_foreign_key "attachments", "notes"
  add_foreign_key "notes", "patients"
  add_foreign_key "notes", "users"
  add_foreign_key "patients", "users"
  add_foreign_key "vocabularies", "users"
end
