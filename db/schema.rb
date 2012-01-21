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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120119192944) do

  create_table "account_settings", :force => true do |t|
    t.integer  "account_id"
    t.integer  "setting_id"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounts", :force => true do |t|
    t.string   "name",        :null => false
    t.text     "description"
    t.string   "full_domain", :null => false
    t.string   "logo_url"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["full_domain"], :name => "index_accounts_on_full_domain"

  create_table "admins", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assignments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "default_grants", :force => true do |t|
    t.integer  "privilege_id"
    t.integer  "default_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "default_roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grants", :force => true do |t|
    t.integer  "privilege_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "menu_items", :force => true do |t|
    t.string   "name"
    t.string   "help_text"
    t.string   "category"
    t.string   "controller"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pictures", :force => true do |t|
    t.string   "name"
    t.string   "content_type"
    t.binary   "data",         :limit => 1048576
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "portlet_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "portlets", :force => true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.string   "portlet_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "privileges", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "controller"
    t.string   "category"
    t.integer  "actions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  create_table "settings", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "default_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_affiliates", :force => true do |t|
    t.string   "name"
    t.decimal  "rate",       :precision => 6, :scale => 4, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
  end

  add_index "subscription_affiliates", ["token"], :name => "index_subscription_affiliates_on_token"

  create_table "subscription_discounts", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.decimal  "amount",                 :precision => 6, :scale => 2, :default => 0.0
    t.boolean  "percent"
    t.date     "start_on"
    t.date     "end_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "apply_to_setup",                                       :default => true
    t.boolean  "apply_to_recurring",                                   :default => true
    t.integer  "trial_period_extension",                               :default => 0
  end

  create_table "subscription_payments", :force => true do |t|
    t.integer  "subscription_id"
    t.decimal  "amount",                    :precision => 10, :scale => 2, :default => 0.0
    t.string   "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "setup"
    t.boolean  "misc"
    t.integer  "subscription_affiliate_id"
    t.decimal  "affiliate_amount",          :precision => 6,  :scale => 2, :default => 0.0
    t.integer  "subscriber_id"
    t.string   "subscriber_type"
  end

  add_index "subscription_payments", ["subscriber_id", "subscriber_type"], :name => "index_payments_on_subscriber"
  add_index "subscription_payments", ["subscription_id"], :name => "index_subscription_payments_on_subscription_id"

  create_table "subscription_plans", :force => true do |t|
    t.string   "name"
    t.decimal  "amount",         :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "renewal_period",                                :default => 1
    t.decimal  "setup_amount",   :precision => 10, :scale => 2
    t.integer  "trial_period",                                  :default => 1
    t.integer  "user_limit"
    t.string   "description"
  end

  create_table "subscriptions", :force => true do |t|
    t.decimal  "amount",                    :precision => 10, :scale => 2
    t.datetime "next_renewal_at"
    t.string   "card_number"
    t.string   "card_expiration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                                    :default => "trial"
    t.integer  "subscription_plan_id"
    t.integer  "subscriber_id"
    t.string   "subscriber_type"
    t.integer  "renewal_period",                                           :default => 1
    t.string   "billing_id"
    t.integer  "subscription_discount_id"
    t.integer  "subscription_affiliate_id"
    t.integer  "user_limit"
  end

  add_index "subscriptions", ["subscriber_id", "subscriber_type"], :name => "index_subscriptions_on_subscriber"

  create_table "users", :force => true do |t|
    t.string   "last_name"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "home_phone"
    t.string   "work_phone"
    t.string   "mobile_phone"
    t.string   "email",                                   :null => false
    t.string   "encrypted_password",                      :null => false
    t.string   "password_salt",                           :null => false
    t.datetime "last_sign_in_at"
    t.datetime "current_sign_in_at"
    t.string   "last_sign_in_ip"
    t.string   "current_sign_in_ip"
    t.integer  "account_id"
    t.integer  "customer_id"
    t.boolean  "owner",                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",        :default => 0
    t.integer  "failed_attempts",      :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
  end

  add_index "users", ["account_id"], :name => "index_users_on_account_id"
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

end
