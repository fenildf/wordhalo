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

ActiveRecord::Schema.define(version: 20140727062004) do

  create_table "cards", force: true do |t|
    t.datetime "schedule"
    t.boolean  "pending"
    t.integer  "study_count"
    t.string   "study_type"
    t.integer  "word_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "new_words", force: true do |t|
    t.integer  "user_id"
    t.integer  "word_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sentences", force: true do |t|
    t.integer  "word_id"
    t.integer  "version"
    t.integer  "index"
    t.string   "english"
    t.string   "chinese"
    t.string   "actual"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.date     "last_study_date"
    t.integer  "study_card_count"
    t.integer  "study_new_word_count"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

  create_table "words", force: true do |t|
    t.integer  "version"
    t.string   "title"
    t.string   "pronounce"
    t.string   "serialized_chinese"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "words", ["title"], name: "index_words_on_title", unique: true

end
