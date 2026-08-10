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

ActiveRecord::Schema[8.1].define(version: 2026_08_10_183000) do
  create_table "active_admin_comments", force: :cascade do |t|
    t.integer "author_id"
    t.string "author_type"
    t.text "body"
    t.datetime "created_at", null: false
    t.string "namespace"
    t.integer "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "addresses", force: :cascade do |t|
    t.string "address_line1", null: false
    t.string "address_line2"
    t.integer "addressable_id"
    t.string "addressable_type"
    t.string "city", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "zip", null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "product_family_id"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["product_family_id"], name: "index_categories_on_product_family_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.string "end_address", null: false
    t.decimal "factor", precision: 3, scale: 2, null: false
    t.integer "km", null: false
    t.text "purpose", null: false
    t.string "start_address", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_expenses_on_user_id"
  end

  create_table "product_families", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.boolean "active", default: false
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.decimal "ekp"
    t.text "menu_description"
    t.boolean "print_on_menu"
    t.integer "stock_target"
    t.string "stock_unit"
    t.integer "supplier_id"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.decimal "uvp"
    t.decimal "vkp"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["supplier_id"], name: "index_products_on_supplier_id"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "contact_email"
    t.string "contact_phone"
    t.datetime "created_at", null: false
    t.string "description"
    t.string "personal_contact_name"
    t.string "preffered_time_to_order"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "website"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "family_name"
    t.string "given_name", null: false
    t.datetime "locked_at"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "work_schedule_days", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.text "notes"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "work_schedule_id", null: false
    t.index ["work_schedule_id", "date"], name: "index_work_schedule_days_on_work_schedule_id_and_date", unique: true
    t.index ["work_schedule_id"], name: "index_work_schedule_days_on_work_schedule_id"
  end

  create_table "work_schedules", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "ends_on", null: false
    t.text "notes"
    t.date "starts_on", null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["starts_on", "ends_on"], name: "index_work_schedules_on_starts_on_and_ends_on"
    t.index ["status"], name: "index_work_schedules_on_status"
  end

  create_table "work_shifts", force: :cascade do |t|
    t.integer "break_minutes", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "ends_at", null: false
    t.text "notes"
    t.string "position", null: false
    t.datetime "starts_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "work_schedule_day_id", null: false
    t.index ["user_id", "starts_at", "ends_at"], name: "index_work_shifts_on_user_id_and_starts_at_and_ends_at"
    t.index ["user_id"], name: "index_work_shifts_on_user_id"
    t.index ["work_schedule_day_id", "starts_at"], name: "index_work_shifts_on_work_schedule_day_id_and_starts_at"
    t.index ["work_schedule_day_id"], name: "index_work_shifts_on_work_schedule_day_id"
  end

  create_table "working_hours", force: :cascade do |t|
    t.integer "break_minutes"
    t.datetime "created_at", null: false
    t.date "date"
    t.integer "duration_minutes"
    t.datetime "end_at"
    t.datetime "start_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_working_hours_on_user_id"
  end

  add_foreign_key "categories", "product_families"
  add_foreign_key "expenses", "users"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "suppliers"
  add_foreign_key "work_schedule_days", "work_schedules"
  add_foreign_key "work_shifts", "users"
  add_foreign_key "work_shifts", "work_schedule_days"
  add_foreign_key "working_hours", "users"
end
