require 'rails_helper'

describe 'Admin - Bénéficiaires', type: :feature do
  describe 'show' do
    context "quand le conseiller n'a pas accès" do
      let!(:conseiller) { create :compte_conseiller, :structure_avec_admin }
      let!(:autre_conseiller) { create :compte_conseiller, :structure_avec_admin }
      let!(:beneficiaire) { create :beneficiaire }
      let!(:campagne_visible) {
        create :campagne, :avec_parcours_positionnement, compte: conseiller }
      let!(:autre_campagne) {
        create :campagne, :avec_parcours_positionnement, compte: autre_conseiller }
      let!(:evaluation_visible) do
        create(
          :evaluation,
          :eva,
          beneficiaire: beneficiaire,
          campagne: campagne_visible
        )
      end
      let!(:evaluation_non_visible) do
        create(:evaluation, :eva, :positionnement, beneficiaire: beneficiaire,
          campagne: autre_campagne)
      end

      before { connecte(conseiller) }

      it "le conseiller voit uniquement les évaluations auxquelles il a accès" do
        Bullet.enable = false if defined?(Bullet)

        visit admin_beneficiaire_path(beneficiaire)

        expect(page).to have_css("[data-id='#{evaluation_visible.id}']")
        expect(page).not_to have_css("[data-id='#{evaluation_non_visible.id}']")

        Bullet.enable = true if defined?(Bullet)
      end
    end
  end

  describe "index" do
    context "en tant qu'admin" do
      let!(:structure) { create :structure_locale, :avec_admin }
      let!(:compte_admin) { create :compte_admin, structure: structure }

      before do
        connecte(compte_admin)
        visit admin_beneficiaires_path
      end

      it "n'affiche pas le bouton 'Nouveau bénéficiaire'" do
        expect(page).not_to have_content("Nouveau bénéficiaire")
        expect(page).not_to have_link("Nouveau bénéficiaire")
      end
    end

    context "colonne Suivi" do
      let!(:compte_admin) { create :compte_admin }
      let(:campagne) { create :campagne, compte: compte_admin }

      before do
        create :evaluation, :eva, campagne: campagne
        connecte(compte_admin)
      end

      it "affiche la colonne Suivi entre le code bénéficiaire et la date de création" do
        visit admin_beneficiaires_path

        entetes = all("thead th").map(&:text)
        position = ->(titre) { entetes.index { _1.start_with?(titre) } }
        expect(position.call("Suivi")).to eq position.call("Code bénéficiaire") + 1
        expect(position.call("Créé le")).to eq position.call("Suivi") + 1
      end
    end

    context "tri par statut de suivi" do
      let!(:compte_admin) { create :compte_admin }
      let(:campagne) { create :campagne, compte: compte_admin }
      let(:attributs_concernee) do
        { campagne: campagne, synthese_competences_de_base: :illettrisme_potentiel,
          completude: "complete" }
      end
      let!(:non_concerne) { create(:evaluation, :eva, campagne: campagne).beneficiaire }
      let!(:a_renseigner) { create(:evaluation, :eva, attributs_concernee).beneficiaire }
      let!(:suite_engagee) do
        create(:evaluation, :eva, :avec_mise_en_action, effectuee: true,
                                                        **attributs_concernee).beneficiaire
      end

      before do
        Bullet.enable = false
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("DATE_STATUT_SUIVI").and_return("2020-01-01")
        connecte(compte_admin)
      end

      after { Bullet.enable = true }

      it "trie dans l'ordre des statuts, les non concernés en dernier" do
        visit admin_beneficiaires_path
        click_link "Suivi"

        codes = [ suite_engagee, a_renseigner, non_concerne ].map(&:code_beneficiaire)
        expect(find("tbody").text).to match(/#{codes.join(".*")}/m)
      end

      it "inverse l'ordre au second clic" do
        visit admin_beneficiaires_path
        click_link "Suivi"
        click_link "Suivi"

        codes = [ non_concerne, a_renseigner, suite_engagee ].map(&:code_beneficiaire)
        expect(find("tbody").text).to match(/#{codes.join(".*")}/m)
      end
    end

    context "filtre Suivi" do
      let!(:compte_admin) { create :compte_admin }
      let(:campagne) { create :campagne, compte: compte_admin }
      let(:autre_campagne) { create :campagne, compte: compte_admin }
      let(:attributs_concernee) do
        { synthese_competences_de_base: :illettrisme_potentiel, completude: "complete" }
      end
      let!(:non_concerne) { create(:evaluation, :eva, campagne: campagne).beneficiaire }
      let!(:a_renseigner) do
        create(:evaluation, :eva, campagne: campagne, **attributs_concernee).beneficiaire
      end
      let!(:a_renseigner_autre_campagne) do
        create(:evaluation, :eva, campagne: autre_campagne, **attributs_concernee).beneficiaire
      end

      before do
        Bullet.enable = false
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("DATE_STATUT_SUIVI").and_return("2020-01-01")
        connecte(compte_admin)
      end

      after { Bullet.enable = true }

      it "propose les statuts dans le panneau de recherche" do
        visit admin_beneficiaires_path

        libelles = all("#q_statut_suivi_input details label", visible: :all)
                   .map { _1.text(:all).strip }
        expect(libelles).to eq [ "À renseigner", "Reporté", "Suite engagée", "Pas de suite" ]
      end

      it "ne garde que les bénéficiaires des statuts choisis" do
        visit admin_beneficiaires_path(q: { statut_suivi_in: [ "a_renseigner" ] })

        expect(page).to have_content(a_renseigner.code_beneficiaire)
        expect(page).not_to have_content(non_concerne.code_beneficiaire)
      end

      it "se combine avec le filtre campagne" do
        visit admin_beneficiaires_path(q: { statut_suivi_in: [ "a_renseigner" ],
                                            evaluations_campagne_id_eq: campagne.id })

        expect(page).to have_content(a_renseigner.code_beneficiaire)
        expect(page).not_to have_content(a_renseigner_autre_campagne.code_beneficiaire)
      end
    end

    context "avec une sélection" do
      let!(:compte_admin) { create :compte_admin }
      let(:campagne) { create :campagne, compte: compte_admin }
      let!(:selectionne) { create(:evaluation, :eva, campagne: campagne).beneficiaire }
      let!(:hors_selection) { create(:evaluation, :eva, campagne: campagne).beneficiaire }
      let!(:hors_perimetre) { create(:evaluation, :eva).beneficiaire }

      before do
        Bullet.enable = false
        connecte(compte_admin)
        visit admin_beneficiaires_path(selection: [ selectionne.id, hors_perimetre.id ])
      end

      after { Bullet.enable = true }

      it "affiche tous les bénéficiaires du périmètre du compte" do
        expect(page).to have_content(selectionne.code_beneficiaire)
        expect(page).to have_content(hors_selection.code_beneficiaire)
        expect(page).not_to have_content(hors_perimetre.code_beneficiaire)
      end

      it "coche seulement les bénéficiaires de la sélection" do
        expect(page).to have_checked_field("beneficiaire_ids[]", with: selectionne.id,
                                                                 visible: :all)
        expect(page).to have_unchecked_field("beneficiaire_ids[]", with: hors_selection.id,
                                                                   visible: :all)
      end
    end
  end

  describe "suivi groupé", :js do
    let!(:compte_admin) { create :compte_admin }
    let(:campagne) { create :campagne, compte: compte_admin }
    let(:attributs_concernee) do
      { campagne: campagne, synthese_competences_de_base: :illettrisme_potentiel,
        completude: "complete" }
    end
    let!(:premier) { create(:evaluation, :eva, attributs_concernee).beneficiaire }
    let!(:second) { create(:evaluation, :eva, attributs_concernee).beneficiaire }
    let!(:non_coche) { create(:evaluation, :eva, attributs_concernee).beneficiaire }

    before do
      Bullet.enable = false
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("DATE_STATUT_SUIVI").and_return("2020-01-01")
      connecte(compte_admin)
      # En mode JS, la connexion n'est pas terminée au retour de connecte
      page.assert_current_path(admin_dashboard_path)
    end

    after { Bullet.enable = true }

    def coche(beneficiaire)
      find("tr", text: beneficiaire.code_beneficiaire).find("label").click
    end

    it "renvoie sur tous les bénéficiaires, la sélection cochée et à jour" do
      visit admin_beneficiaires_path(q: { statut_suivi_in: [ "a_renseigner" ] })
      [ premier, second ].each { |beneficiaire| coche(beneficiaire) }
      expect(page).to have_content(I18n.t("components.tableau.lignes_selectionnees", count: 2))
      click_button I18n.t("admin.beneficiaires.actions_groupees.renseigner_suivi")
      click_button I18n.t("admin.beneficiaires.modal_suivi_groupe.oui")
      click_on I18n.t(
        "activerecord.attributes.mise_en_action.remediation.formation_competences_de_base"
      )
      click_button I18n.t("admin.beneficiaires.modal_suivi_groupe.enregistrer")

      expect(page).to have_content(
        I18n.t("admin.beneficiaires.renseigner_suivi_groupe.success.titre", count: 2)
      )
      expect(page).to have_content(non_coche.code_beneficiaire)
      expect(page).to have_unchecked_field("beneficiaire_ids[]", with: non_coche.id,
                                                                 visible: :all)
      [ premier, second ].each do |beneficiaire|
        ligne = find("tr", text: beneficiaire.code_beneficiaire)
        expect(ligne).to have_content(I18n.t("statut_suivi.suite_engagee"))
        expect(ligne).to have_checked_field("beneficiaire_ids[]", with: beneficiaire.id,
                                                                  visible: :all)
      end
      expect(page).to have_content(I18n.t("components.tableau.lignes_selectionnees", count: 2))
      expect(page).to have_button(I18n.t("admin.beneficiaires.actions_groupees.renseigner_suivi"),
                                  disabled: false)
    end

    it "fusionne les bénéficiaires sélectionnés dans le plus ancien" do
      visit admin_beneficiaires_path
      expect(page).to have_button(I18n.t("admin.beneficiaires.actions_groupees.fusionner"),
                                  disabled: true)
      [ premier, second ].each { |beneficiaire| coche(beneficiaire) }
      click_button I18n.t("admin.beneficiaires.actions_groupees.fusionner")
      within("#fr-modal-fusionner") do
        expect(page).to have_css("li", count: 2)
        click_button I18n.t("admin.beneficiaires.modal_fusion.confirmer")
      end

      expect(page).to have_current_path(admin_beneficiaire_path(premier))
      expect(page).to have_content(
        I18n.t("admin.beneficiaires.fusion.success.notice", beneficiaire_nom: premier.nom)
      )
    end
  end
end
