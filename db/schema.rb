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

ActiveRecord::Schema.define(:version => 20120128214452) do

  create_table "alert_deliveries", :force => true do |t|
    t.integer  "alert_id",                                         :null => false
    t.string   "workitem_id"
    t.string   "recipient",                                        :null => false
    t.string   "delivery_method",                                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reply",           :limit => 32
    t.boolean  "silenced",                      :default => false
    t.string   "slug",            :limit => 32
  end

  add_index "alert_deliveries", ["slug"], :name => "index_alert_deliveries_on_slug"

  create_table "alerts", :force => true do |t|
    t.integer  "process_definition_id"
    t.string   "subject"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "resolution",            :limit => 64
    t.integer  "resolved_by_id"
    t.string   "resolver"
    t.integer  "customer_id"
  end

  create_table "customers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "process_definitions", :force => true do |t|
    t.string   "name"
    t.string   "launch_alias",   :limit => 37
    t.text     "definition"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                       :default => true, :null => false
    t.string   "subject_filter"
    t.integer  "customer_id",                                    :null => false
    t.string   "time_zone"
  end

  add_index "process_definitions", ["customer_id", "active"], :name => "index_process_definitions_on_customer_id_and_active"
  add_index "process_definitions", ["launch_alias", "active"], :name => "index_process_definitions_on_launch_alias_and_active"

  create_table "reply_choices", :force => true do |t|
    t.integer  "alert_delivery_id", :null => false
    t.string   "reply",             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "silenced_recipients", :force => true do |t|
    t.string   "recipient",       :null => false
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "delivery_method"
  end

  add_index "silenced_recipients", ["recipient", "delivery_method"], :name => "index_silenced_recipients_on_recipient_and_delivery_method"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",                       :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id",                                           :null => false
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

end
