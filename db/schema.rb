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

ActiveRecord::Schema[7.2].define(version: 2026_02_02_103000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bookings", force: :cascade do |t|
    t.date "checkin_date"
    t.date "checkout_date"
    t.bigint "car_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.string "pickup_mode"
    t.string "pickup_address"
    t.time "pickup_time"
    t.time "return_time"
    t.integer "drivers_count"
    t.integer "driver_age"
    t.integer "license_years"
    t.boolean "premium_insurance", default: false, null: false
    t.boolean "child_seat", default: false, null: false
    t.boolean "gps", default: false, null: false
    t.boolean "terms_accepted", default: false, null: false
    t.datetime "owner_notified_at"
    t.datetime "owner_reminded_at"
    t.datetime "renter_warning_sent_at"
    t.boolean "deposit_card", default: false, null: false
    t.string "payment_status", default: "unpaid", null: false
    t.string "stripe_session_id"
    t.string "stripe_payment_intent_id"
    t.datetime "paid_at"
    t.datetime "refunded_at"
    t.string "paypal_order_id"
    t.string "paypal_capture_id"
    t.index ["car_id"], name: "index_bookings_on_car_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "cars", force: :cascade do |t|
    t.string "brand"
    t.string "category"
    t.string "model"
    t.string "address"
    t.integer "price"
    t.boolean "status"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "year"
    t.text "description"
    t.text "photo_order"
    t.index ["user_id"], name: "index_cars_on_user_id"
  end

  create_table "contract_settings", force: :cascade do |t|
    t.string "company_name"
    t.string "company_address"
    t.string "company_vat"
    t.string "company_email"
    t.string "contract_version", default: "3.0", null: false
    t.string "jurisdiction", default: "Union Européenne / France", null: false
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["updated_by_id"], name: "index_contract_settings_on_updated_by_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "booking_id"
    t.string "kind", null: false
    t.string "title", null: false
    t.text "body"
    t.string "link_path"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_notifications_on_booking_id"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "owner_request_events", force: :cascade do |t|
    t.bigint "owner_request_id", null: false
    t.bigint "actor_id"
    t.string "action", null: false
    t.string "from_status"
    t.string "to_status"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_owner_request_events_on_actor_id"
    t.index ["owner_request_id"], name: "index_owner_request_events_on_owner_request_id"
  end

  create_table "owner_requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "signature_method", default: 0, null: false
    t.boolean "contract_accepted", default: false, null: false
    t.datetime "contract_accepted_at"
    t.datetime "submitted_at"
    t.string "id_document_type"
    t.string "id_number"
    t.date "id_expires_on"
    t.string "driver_license_number"
    t.date "driver_license_expires_on"
    t.date "proof_of_address_issued_on"
    t.string "residence_country"
    t.string "bank_iban"
    t.string "bank_bic"
    t.string "bank_holder_name"
    t.boolean "work_permit_required", default: false, null: false
    t.date "work_permit_expires_on"
    t.bigint "reviewed_by_id"
    t.datetime "approved_at"
    t.datetime "rejected_at"
    t.datetime "needs_contract_at"
    t.text "rejection_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "civility"
    t.string "first_name"
    t.string "last_name"
    t.date "birth_date"
    t.string "birth_city"
    t.string "birth_country"
    t.string "nationality"
    t.string "gender"
    t.string "address_line1"
    t.string "address_line2"
    t.string "postal_code"
    t.string "city"
    t.string "country"
    t.string "phone"
    t.boolean "cgu_accepted", default: false, null: false
    t.datetime "cgu_accepted_at"
    t.index ["reviewed_by_id"], name: "index_owner_requests_on_reviewed_by_id"
    t.index ["status"], name: "index_owner_requests_on_status"
    t.index ["user_id"], name: "index_owner_requests_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role"
    t.string "phone"
    t.string "phone_country"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bookings", "cars"
  add_foreign_key "bookings", "users"
  add_foreign_key "cars", "users"
  add_foreign_key "contract_settings", "users", column: "updated_by_id"
  add_foreign_key "notifications", "bookings"
  add_foreign_key "notifications", "users"
  add_foreign_key "owner_request_events", "owner_requests"
  add_foreign_key "owner_request_events", "users", column: "actor_id"
  add_foreign_key "owner_requests", "users"
  add_foreign_key "owner_requests", "users", column: "reviewed_by_id"
end
