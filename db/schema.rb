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

ActiveRecord::Schema.define(:version => 20130503190140) do

  create_table "available_times", :force => true do |t|
    t.integer  "reservation_set_id"
    t.time     "reservation_time"
    t.integer  "tables_available"
    t.integer  "tables_sold"
    t.integer  "tables_unsold"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "bars", :force => true do |t|
    t.string   "name"
    t.integer  "phone_number",        :limit => 8
    t.string   "address"
    t.text     "intro_paragraph"
    t.integer  "user_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.float    "latitude"
    t.float    "longitude"
    t.string   "logo"
    t.string   "website_url"
    t.string   "facebook_url"
    t.string   "twitter_url"
    t.boolean  "open_monday"
    t.boolean  "open_tuesday"
    t.boolean  "open_wednesday"
    t.boolean  "open_thursday"
    t.boolean  "open_saturday"
    t.boolean  "open_sunday"
    t.time     "houropen_monday"
    t.time     "houropen_tuesday"
    t.time     "hourclose_tuesday"
    t.time     "hourclose_wednesday"
    t.time     "houropen_wednesday"
    t.time     "houropen_thursday"
    t.time     "hourclose_thursday"
    t.time     "houropen_friday"
    t.time     "hourclose_friday"
    t.time     "houropen_saturday"
    t.time     "hourclose_saturday"
    t.time     "hourclose_sunday"
    t.boolean  "open_friday"
    t.time     "hourclose_monday"
    t.time     "houropen_sunday"
    t.string   "street_address"
    t.string   "city"
    t.string   "zip_code"
    t.string   "state"
    t.string   "slug"
  end

  add_index "bars", ["user_id"], :name => "index_bars_on_user_id"

  create_table "deal_sets", :force => true do |t|
    t.integer  "fecha_id"
    t.integer  "total_released_deals"
    t.integer  "sold_deals"
    t.integer  "unsold_deals"
    t.decimal  "revenue_total"
    t.decimal  "revenue_percentage"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "location_id"
    t.integer  "event_id"
  end

  create_table "deals", :force => true do |t|
    t.integer  "deal_set_id"
    t.integer  "purchase_id"
    t.string   "name"
    t.boolean  "redeemed"
    t.integer  "entries"
    t.decimal  "price"
    t.string   "confirmation"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.decimal  "total_price"
  end

  create_table "dia", :force => true do |t|
    t.integer  "location_id"
    t.boolean  "selling_passes"
    t.boolean  "selling_reservations"
    t.boolean  "selling_tickets"
    t.boolean  "selling_deals"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "events", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "phone_number"
    t.string   "address"
    t.text     "intro_paragraph"
    t.date     "date_of_event"
    t.time     "time_of_event"
    t.float    "latitude"
    t.string   "logo"
    t.string   "website_url"
    t.string   "facebook_url"
    t.string   "twitter_url"
    t.string   "street_address"
    t.string   "city"
    t.integer  "zip_code"
    t.string   "state"
    t.string   "slug"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.float    "longitude"
  end

  create_table "fechas", :force => true do |t|
    t.integer  "location_id"
    t.boolean  "selling_passes",       :default => false
    t.boolean  "selling_reservations", :default => false
    t.boolean  "selling_tickets",      :default => false
    t.boolean  "selling_deals",        :default => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "ticket_set_id"
    t.date     "date"
    t.integer  "pass_set_id"
    t.integer  "deal_set_id"
    t.integer  "reservation_set_id"
    t.integer  "event_id"
  end

  create_table "friend_purchases", :force => true do |t|
    t.integer  "pass_id"
    t.integer  "deal_id"
    t.integer  "ticket_id"
    t.integer  "reservation_id"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "location_hours", :force => true do |t|
    t.integer  "location_id"
    t.string   "day_of_week_open"
    t.text     "day_of_week_close"
    t.time     "opening_time"
    t.time     "closing_time"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "event_id"
  end

  create_table "locations", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "phone_number"
    t.string   "street_address"
    t.text     "intro_paragraph"
    t.float    "latitude"
    t.string   "logo"
    t.string   "website_url"
    t.string   "facebook_url"
    t.string   "twitter_url"
    t.string   "full_address"
    t.string   "city"
    t.string   "zip_code"
    t.string   "state"
    t.string   "slug"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.float    "longitude"
  end

  create_table "menu_items", :force => true do |t|
    t.integer  "location_id"
    t.string   "name"
    t.decimal  "price"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "pass_friends", :force => true do |t|
    t.integer  "pass_id"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "pass_sets", :force => true do |t|
    t.integer  "bar_id"
    t.date     "date"
    t.integer  "total_released_passes"
    t.integer  "sold_passes"
    t.integer  "unsold_passes"
    t.decimal  "price",                    :precision => 10, :scale => 2
    t.datetime "created_at",                                                               :null => false
    t.datetime "updated_at",                                                               :null => false
    t.boolean  "selling_passes"
    t.decimal  "revenue_total",            :precision => 10, :scale => 2, :default => 0.0
    t.text     "description"
    t.boolean  "reservation_time_periods"
    t.boolean  "friend_check"
    t.integer  "location_id"
    t.integer  "fecha_id"
    t.decimal  "revenue_percentage"
    t.integer  "event_id"
  end

  add_index "pass_sets", ["bar_id"], :name => "index_pass_sets_on_bar_id"

  create_table "passes", :force => true do |t|
    t.integer  "pass_set_id"
    t.integer  "purchase_id"
    t.string   "name"
    t.boolean  "redeemed"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "entries",          :default => 0
    t.integer  "price"
    t.string   "confirmation"
    t.string   "reservation_time"
    t.decimal  "total_price"
  end

  add_index "passes", ["confirmation"], :name => "index_passes_on_confirmation"
  add_index "passes", ["pass_set_id"], :name => "index_passes_on_Pass_Set_id"
  add_index "passes", ["purchase_id"], :name => "index_passes_on_Purchase_id"

  create_table "photos", :force => true do |t|
    t.integer  "location_id"
    t.string   "file_name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "price_points", :force => true do |t|
    t.integer  "pass_set_id"
    t.integer  "reservation_set_id"
    t.integer  "ticket_set_id"
    t.decimal  "price"
    t.integer  "num_released"
    t.integer  "num_sold"
    t.integer  "num_unsold"
    t.text     "description"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "deal_set_id"
  end

  create_table "purchases", :force => true do |t|
    t.date     "date"
    t.integer  "user_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "stripe_card_token"
    t.string   "stripe_charge_token"
  end

  add_index "purchases", ["user_id"], :name => "index_purchases_on_user_id"

  create_table "reservation_sets", :force => true do |t|
    t.integer  "fecha_id"
    t.integer  "total_released_reservations"
    t.integer  "sold_reservations"
    t.integer  "unsold_reservations"
    t.decimal  "revenue_total"
    t.decimal  "revenue_percentage"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.boolean  "reservation_time_periods"
    t.integer  "location_id"
    t.integer  "event_id"
  end

  create_table "reservations", :force => true do |t|
    t.integer  "reservation_set_id"
    t.integer  "purchase_id"
    t.string   "name"
    t.boolean  "redeemed"
    t.integer  "entries"
    t.decimal  "price"
    t.string   "confirmation"
    t.string   "reservation_time"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.decimal  "total_price"
  end

  create_table "specials", :force => true do |t|
    t.integer  "location_id"
    t.string   "name"
    t.decimal  "price"
    t.date     "available_start"
    t.date     "available_end"
    t.text     "description"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "ticket_sets", :force => true do |t|
    t.integer  "fecha_id"
    t.integer  "total_released_tickets"
    t.integer  "sold_tickets"
    t.integer  "unsold_tickets"
    t.decimal  "revenue_total"
    t.decimal  "revenue_percentage"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "location_id"
    t.integer  "event_id"
  end

  create_table "tickets", :force => true do |t|
    t.integer  "ticket_set_id"
    t.integer  "purchase_id"
    t.string   "name"
    t.boolean  "redeemed"
    t.integer  "entries"
    t.decimal  "price"
    t.string   "confirmation"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.decimal  "total_price"
  end

  create_table "time_periods", :force => true do |t|
    t.boolean  "ten_am_available"
    t.integer  "ten_am_tables"
    t.boolean  "ten_thirty_am_available"
    t.integer  "ten_thirty_am_tables"
    t.boolean  "eleven_am_available"
    t.integer  "eleven_am_tables"
    t.boolean  "eleven_thirty_am_available"
    t.integer  "eleven_thirty_am_tables"
    t.boolean  "twelve_pm_available"
    t.integer  "twelve_pm_tables"
    t.boolean  "twelve_thirty_pm_available"
    t.integer  "twelve_thirty_pm_tables"
    t.boolean  "one_pm_available"
    t.integer  "one_pm_tables"
    t.boolean  "one_thirty_pm_available"
    t.integer  "one_thirty_pm_tables"
    t.boolean  "two_pm_available"
    t.integer  "two_pm_tables"
    t.boolean  "two_thirty_pm_available"
    t.integer  "two_thirty_pm_tables"
    t.boolean  "three_pm_available"
    t.integer  "three_pm_tables"
    t.boolean  "three_thirty_pm_available"
    t.integer  "three_thirty_pm_tables"
    t.boolean  "four_pm_available"
    t.integer  "four_pm_tables"
    t.boolean  "four_thirty_pm_available"
    t.integer  "four_thirty_pm_tables"
    t.boolean  "five_pm_available"
    t.integer  "five_pm_tables"
    t.boolean  "five_thirty_pm_available"
    t.integer  "five_thirty_pm_tables"
    t.boolean  "six_pm_available"
    t.integer  "six_pm_tables"
    t.boolean  "six_thirty_pm_available"
    t.integer  "six_thirty_pm_tables"
    t.boolean  "seven_pm_available"
    t.integer  "seven_pm_tables"
    t.boolean  "seven_thirty_pm_available"
    t.integer  "seven_thirty_pm_tables"
    t.boolean  "eight_pm_available"
    t.integer  "eight_pm_tables"
    t.boolean  "eight_thirty_pm_available"
    t.integer  "eight_thirty_pm_tables"
    t.boolean  "nine_pm_available"
    t.integer  "nine_pm_tables"
    t.boolean  "nine_thirty_pm_available"
    t.integer  "nine_thirty_pm_tables"
    t.boolean  "ten_pm_available"
    t.integer  "ten_pm_tables"
    t.integer  "pass_set_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "name"
    t.boolean  "admin",                  :default => false, :null => false
    t.boolean  "partner",                :default => false, :null => false
    t.string   "provider"
    t.string   "uid"
    t.string   "stripe_customer_token"
    t.string   "stripe_card_token"
    t.string   "authentication_token"
    t.string   "error_message"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
