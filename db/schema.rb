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

ActiveRecord::Schema[8.1].define(version: 2026_03_09_022725) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "day_templates", force: :cascade do |t|
    t.integer "breakfast"
    t.datetime "created_at", null: false
    t.string "day_name"
    t.integer "dinner"
    t.integer "lunch"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_day_templates_on_user_id"
  end

  create_table "days", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "date"
    t.datetime "updated_at", null: false
    t.bigint "week_id", null: false
    t.index ["week_id"], name: "index_days_on_week_id"
  end

  create_table "dishes", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.bigint "day_id", null: false
    t.integer "portions"
    t.bigint "recipe_id", null: false
    t.datetime "updated_at", null: false
    t.index ["day_id"], name: "index_dishes_on_day_id"
    t.index ["recipe_id"], name: "index_dishes_on_recipe_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "recipe_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["recipe_id"], name: "index_favorites_on_recipe_id"
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "ingredients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "recipe_items", force: :cascade do |t|
    t.float "amount"
    t.datetime "created_at", null: false
    t.bigint "ingredient_id", null: false
    t.bigint "recipe_id", null: false
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_recipe_items_on_ingredient_id"
    t.index ["recipe_id"], name: "index_recipe_items_on_recipe_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.integer "cooktime"
    t.datetime "created_at", null: false
    t.string "cuisine"
    t.string "image_url"
    t.text "instructions"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "shopping_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "ingredient_id", null: false
    t.boolean "purchased"
    t.float "total"
    t.string "unit"
    t.datetime "updated_at", null: false
    t.bigint "week_id", null: false
    t.index ["ingredient_id"], name: "index_shopping_items_on_ingredient_id"
    t.index ["week_id"], name: "index_shopping_items_on_week_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "allergies", array: true
    t.datetime "created_at", null: false
    t.string "disease", array: true
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "preferred_cuisines", array: true
    t.string "preferred_ingredients", array: true
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "undesireable_ingredients", array: true
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "weeks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "month"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_weeks_on_user_id"
  end

  add_foreign_key "day_templates", "users"
  add_foreign_key "days", "weeks"
  add_foreign_key "dishes", "days"
  add_foreign_key "dishes", "recipes"
  add_foreign_key "favorites", "recipes"
  add_foreign_key "favorites", "users"
  add_foreign_key "recipe_items", "ingredients"
  add_foreign_key "recipe_items", "recipes"
  add_foreign_key "shopping_items", "ingredients"
  add_foreign_key "shopping_items", "weeks"
  add_foreign_key "weeks", "users"
end
