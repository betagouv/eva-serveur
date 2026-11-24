require "rails_helper"

describe "Admin - Listes des référentiels", type: :feature do
  before do
    Bullet.enable = false
    se_connecter_comme_superadmin
  end

  after { Bullet.enable = true }

  {
    AnnonceGenerale => [ :admin_annonce_generales_path, ->(nom) {
 AnnonceGenerale.create!(texte: nom) } ],
    Opco => [ :admin_opcos_path, ->(nom) { create :opco, nom: nom } ],
    ParcoursType => [ :admin_parcours_type_index_path, ->(nom) {
 create :parcours_type, libelle: nom } ],
    Questionnaire => [ :admin_questionnaires_path, ->(nom) {
 create :questionnaire, libelle: nom } ],
    QuestionQcm => [ :admin_question_qcms_path, ->(nom) { create :question_qcm, libelle: nom } ],
    QuestionClicDansImage => [ :admin_questions_clic_dans_image_path,
                               ->(nom) { create :question_clic_dans_image, libelle: nom } ],
    QuestionClicDansTexte => [ :admin_questions_clic_dans_texte_path,
                               ->(nom) { create :question_clic_dans_texte, libelle: nom } ],
    QuestionGlisserDeposer => [ :admin_questions_glisser_deposer_path,
                                ->(nom) { create :question_glisser_deposer, libelle: nom } ],
    QuestionSaisie => [ :admin_questions_saisies_path, ->(nom) {
 create :question_saisie, libelle: nom } ],
    QuestionSousConsigne => [ :admin_question_sous_consignes_path,
                              ->(nom) { create :question_sous_consigne, libelle: nom } ],
    Situation => [ :admin_situations_path, ->(nom) { create :situation, libelle: nom } ],
    SourceAide => [ :admin_source_aides_path, ->(nom) { create :source_aide, titre: nom } ]
  }.each do |modele, (chemin, cree)|
    describe modele.model_name.human(count: 2) do
      before do
        instance_exec("Recherché alpha", &cree)
        instance_exec("Autre bravo", &cree)
      end

      it "affiche le tableau du DSFR dans le cadre d'ActiveAdmin, avec ses filtres" do
        visit public_send(chemin)

        expect(page).to have_css("h2#page_title", text: modele.model_name.human(count: 2))
        expect(page).to have_css("#filters_sidebar_section")
        expect(page).to have_css(".fr-table table")
        expect(page).to have_content("Recherché alpha")
        expect(page).to have_content("Autre bravo")
      end
    end
  end
end
