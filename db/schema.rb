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

ActiveRecord::Schema[7.0].define(version: 2022_10_31_165243) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_admin_comments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.string "author_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "resource_id"
    t.uuid "author_id"
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
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.uuid "active_storage_blobs_id"
    t.index ["active_storage_blobs_id"], name: "index_active_storage_variant_records_on_active_storage_blobs_id"
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "actualites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "titre"
    t.text "contenu"
    t.integer "categorie"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "annonce_generales", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "texte"
    t.boolean "afficher"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "beneficiaires", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "nom"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "anonymise_le"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_beneficiaires_on_deleted_at"
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
    t.uuid "parcours_type_id"
    t.datetime "anonymise_le"
    t.datetime "deleted_at"
    t.index ["code"], name: "index_campagnes_on_code", unique: true
    t.index ["compte_id"], name: "index_campagnes_on_compte_id"
    t.index ["deleted_at"], name: "index_campagnes_on_deleted_at"
    t.index ["parcours_type_id"], name: "index_campagnes_on_parcours_type_id"
    t.index ["questionnaire_id"], name: "index_campagnes_on_questionnaire_id"
  end

  create_table "choix", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "intitule"
    t.integer "type_choix"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.uuid "question_id"
    t.string "nom_technique"
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
    t.string "role", default: "conseiller"
    t.uuid "structure_id"
    t.integer "statut_validation", default: 0
    t.string "nom"
    t.string "prenom"
    t.string "telephone"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "anonymise_le"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "deleted_at"
    t.index ["confirmation_token"], name: "index_comptes_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_comptes_on_deleted_at"
    t.index ["email"], name: "index_comptes_on_email", unique: true
    t.index ["reset_password_token"], name: "index_comptes_on_reset_password_token", unique: true
    t.index ["structure_id"], name: "index_comptes_on_structure_id"
  end

  create_table "conditions_passations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "evaluation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "version_navigateur"
    t.string "nom_navigateur"
    t.string "modele_materiel"
    t.string "materiel_utilise"
    t.string "user_agent"
    t.integer "hauteur_fenetre_navigation"
    t.integer "largeur_fenetre_navigation"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_conditions_passations_on_deleted_at"
    t.index ["evaluation_id"], name: "index_conditions_passations_on_evaluation_id"
  end

  create_table "donnees_sociodemographiques", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "age"
    t.string "genre"
    t.string "dernier_niveau_etude"
    t.string "derniere_situation"
    t.uuid "evaluation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_donnees_sociodemographiques_on_deleted_at"
    t.index ["evaluation_id"], name: "index_donnees_sociodemographiques_on_evaluation_id"
    t.index ["genre"], name: "index_donnees_sociodemographiques_on_genre"
  end

  create_table "evaluations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "nom"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.uuid "campagne_id"
    t.string "email"
    t.string "telephone"
    t.datetime "terminee_le"
    t.datetime "anonymise_le"
    t.datetime "debutee_le"
    t.string "synthese_competences_de_base"
    t.string "niveau_cefr"
    t.string "niveau_cnef"
    t.string "niveau_anlci_litteratie"
    t.string "niveau_anlci_numeratie"
    t.string "completude", default: "incomplete", null: false
    t.uuid "beneficiaire_id", null: false
    t.datetime "deleted_at"
    t.integer "statut", default: 0, null: false
    t.index ["beneficiaire_id"], name: "index_evaluations_on_beneficiaire_id"
    t.index ["campagne_id"], name: "index_evaluations_on_campagne_id"
    t.index ["deleted_at"], name: "index_evaluations_on_deleted_at"
    t.index ["statut"], name: "index_evaluations_on_statut"
    t.index ["synthese_competences_de_base"], name: "index_evaluations_on_synthese_competences_de_base"
  end

  create_table "evenements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "nom"
    t.jsonb "donnees", default: "{}", null: false
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "session_id"
    t.integer "position"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_evenements_on_deleted_at"
    t.index ["position"], name: "index_evenements_on_position"
    t.index ["session_id", "position"], name: "index_evenements_on_session_id_and_position"
    t.index ["session_id"], name: "index_evenements_on_session_id"
  end

  create_table "parcours_type", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "libelle"
    t.string "nom_technique"
    t.string "duree_moyenne"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "description"
    t.string "categorie"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_parcours_type_on_deleted_at"
  end

  create_table "parties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "session_id"
    t.jsonb "metriques", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "evaluation_id"
    t.uuid "situation_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_parties_on_deleted_at"
    t.index ["evaluation_id"], name: "index_parties_on_evaluation_id"
    t.index ["session_id"], name: "index_parties_on_session_id", unique: true
    t.index ["situation_id"], name: "index_parties_on_situation_id"
  end

  create_table "questionnaires", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "libelle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nom_technique"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_questionnaires_on_deleted_at"
    t.index ["nom_technique"], name: "index_questionnaires_on_nom_technique", unique: true
  end

  create_table "questionnaires_questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.uuid "questionnaire_id"
    t.uuid "question_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_questionnaires_questions_on_deleted_at"
    t.index ["question_id"], name: "index_questionnaires_questions_on_question_id"
    t.index ["questionnaire_id"], name: "index_questionnaires_questions_on_questionnaire_id"
  end

  create_table "questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "intitule"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "type"
    t.string "description"
    t.string "reponse_placeholder"
    t.string "intitule_reponse"
    t.string "libelle"
    t.integer "metacompetence"
    t.integer "type_qcm", default: 0
    t.string "nom_technique"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_questions_on_deleted_at"
  end

  create_table "questions_frequentes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "question"
    t.text "reponse"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "situations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "libelle"
    t.string "nom_technique"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "questionnaire_id"
    t.uuid "questionnaire_entrainement_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_situations_on_deleted_at"
    t.index ["nom_technique"], name: "index_situations_on_nom_technique", unique: true
    t.index ["questionnaire_entrainement_id"], name: "index_situations_on_questionnaire_entrainement_id"
    t.index ["questionnaire_id"], name: "index_situations_on_questionnaire_id"
  end

  create_table "situations_configurations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "campagne_id"
    t.uuid "situation_id"
    t.uuid "questionnaire_id"
    t.uuid "parcours_type_id"
    t.datetime "deleted_at"
    t.index ["campagne_id"], name: "index_situations_configurations_on_campagne_id"
    t.index ["deleted_at"], name: "index_situations_configurations_on_deleted_at"
    t.index ["parcours_type_id"], name: "index_situations_configurations_on_parcours_type_id"
    t.index ["situation_id"], name: "index_situations_configurations_on_situation_id"
  end

  create_table "source_aides", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "titre"
    t.text "description"
    t.string "url"
    t.integer "categorie"
    t.integer "type_document"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "structures", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "nom"
    t.string "code_postal"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "latitude"
    t.float "longitude"
    t.string "type_structure"
    t.string "region"
    t.datetime "anonymise_le"
    t.uuid "structure_referente_id"
    t.string "type"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_structures_on_deleted_at"
    t.index ["latitude", "longitude"], name: "index_structures_on_latitude_and_longitude"
    t.index ["nom", "code_postal"], name: "index_structures_on_nom_and_code_postal", unique: true
    t.index ["structure_referente_id"], name: "index_structures_on_structure_referente_id"
    t.index ["type"], name: "index_structures_on_type"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "active_storage_blobs_id"
  add_foreign_key "campagnes", "comptes"
  add_foreign_key "campagnes", "questionnaires"
  add_foreign_key "choix", "questions", on_delete: :cascade
  add_foreign_key "comptes", "structures"
  add_foreign_key "conditions_passations", "evaluations", on_delete: :cascade
  add_foreign_key "donnees_sociodemographiques", "evaluations", on_delete: :cascade
  add_foreign_key "evaluations", "beneficiaires", on_delete: :cascade
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
