# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_07_152853) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_admin_comments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "resource_id"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.datetime "created_at", null: false
    t.uuid "blob_id"
    t.uuid "record_id"
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "campagnes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "libelle"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "questionnaire_id"
    t.uuid "compte_id"
    t.integer "nombre_evaluations", default: 0
    t.boolean "affiche_competences_fortes", default: true
    t.index ["compte_id"], name: "index_campagnes_on_compte_id"
    t.index ["questionnaire_id"], name: "index_campagnes_on_questionnaire_id"
  end

  create_table "choix", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "intitule"
    t.integer "type_choix"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.uuid "question_id"
    t.index ["question_id"], name: "index_choix_on_question_id"
  end

  create_table "comptes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
    t.index ["email"], name: "index_comptes_on_email", unique: true
    t.index ["reset_password_token"], name: "index_comptes_on_reset_password_token", unique: true
  end

  create_table "evaluations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "nom"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "campagne_id"
    t.index ["campagne_id"], name: "index_evaluations_on_campagne_id"
  end

  create_table "evenements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "nom"
    t.jsonb "donnees", default: {}, null: false
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "session_id"
  end

  create_table "parties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "session_id"
    t.jsonb "metriques", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "evaluation_id"
    t.uuid "situation_id"
    t.index ["evaluation_id"], name: "index_parties_on_evaluation_id"
    t.index ["session_id"], name: "index_parties_on_session_id", unique: true
    t.index ["situation_id"], name: "index_parties_on_situation_id"
  end

  create_table "questionnaires", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "libelle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questionnaires_questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid "questionnaire_id"
    t.uuid "question_id"
    t.index ["question_id"], name: "index_questionnaires_questions_on_question_id"
    t.index ["questionnaire_id"], name: "index_questionnaires_questions_on_questionnaire_id"
  end

  create_table "questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "intitule"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.string "description"
    t.string "entete_reponse"
    t.string "expediteur"
    t.string "message"
    t.string "objet_reponse"
    t.string "libelle"
    t.integer "metacompetence"
  end

  create_table "situations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "libelle"
    t.string "nom_technique"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "questionnaire_id"
    t.uuid "questionnaire_entrainement_id"
    t.index ["questionnaire_entrainement_id"], name: "index_situations_on_questionnaire_entrainement_id"
    t.index ["questionnaire_id"], name: "index_situations_on_questionnaire_id"
  end

  create_table "situations_configurations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "campagne_id"
    t.uuid "situation_id"
    t.index ["campagne_id"], name: "index_situations_configurations_on_campagne_id"
    t.index ["situation_id"], name: "index_situations_configurations_on_situation_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "campagnes", "comptes"
  add_foreign_key "campagnes", "questionnaires"
  add_foreign_key "choix", "questions", on_delete: :cascade
  add_foreign_key "evaluations", "campagnes"
  add_foreign_key "evenements", "parties", column: "session_id", primary_key: "session_id", on_delete: :cascade
  add_foreign_key "parties", "evaluations", on_delete: :cascade
  add_foreign_key "parties", "situations", on_delete: :cascade
  add_foreign_key "questionnaires_questions", "questionnaires"
  add_foreign_key "questionnaires_questions", "questions"
  add_foreign_key "situations", "questionnaires"
  add_foreign_key "situations", "questionnaires", column: "questionnaire_entrainement_id"
  add_foreign_key "situations_configurations", "campagnes"
end
