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
        expect(entetes.index("Suivi")).to eq entetes.index("Code bénéficiaire") + 1
        expect(entetes.index("Créé le")).to eq entetes.index("Suivi") + 1
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

    context "liste restreinte à une sélection" do
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

      it "n'affiche que les bénéficiaires sélectionnés du périmètre du compte" do
        expect(page).to have_content(selectionne.code_beneficiaire)
        expect(page).not_to have_content(hors_selection.code_beneficiaire)
        expect(page).not_to have_content(hors_perimetre.code_beneficiaire)
      end

      it "indique que la liste ne montre que la sélection" do
        expect(page).to have_content(
          I18n.t("admin.beneficiaires.selection.titre", count: 1)
        )
      end

      it "n'affiche pas la restriction dans le panneau Rechercher" do
        expect(find("#filters_sidebar_section")).not_to have_content(selectionne.id)
        expect(page).not_to have_css(".current_filters")
      end

      it "ramène à la liste complète avec « Voir tous les bénéficiaires »" do
        click_link I18n.t("admin.beneficiaires.selection.voir_tous")

        expect(page).to have_content(hors_selection.code_beneficiaire)
        expect(page).not_to have_content(I18n.t("admin.beneficiaires.selection.titre",
                                                count: 1))
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

    it "renvoie sur la sélection, cochée et à jour, après l'enregistrement" do
      visit admin_beneficiaires_path(q: { statut_suivi_in: [ "a_renseigner" ] })
      [ premier, second ].each do |beneficiaire|
        check "batch_action_item_#{beneficiaire.id}", allow_label_click: true
      end
      click_link I18n.t("active_admin.batch_actions.button_label")
      click_link I18n.t("active_admin.batch_actions.labels.renseigner_suivi_groupe")
      click_button I18n.t("admin.beneficiaires.modal_suivi_groupe.oui")
      click_on I18n.t(
        "activerecord.attributes.mise_en_action.remediation.formation_competences_de_base"
      )
      click_button I18n.t("admin.beneficiaires.modal_suivi_groupe.enregistrer")

      expect(page).to have_content(
        I18n.t("admin.beneficiaires.renseigner_suivi_groupe.success.titre", count: 2)
      )
      expect(page).to have_content(I18n.t("admin.beneficiaires.selection.titre", count: 2))
      expect(page).not_to have_content(non_coche.code_beneficiaire)
      [ premier, second ].each do |beneficiaire|
        ligne = find("tr", text: beneficiaire.code_beneficiaire)
        expect(ligne).to have_content(I18n.t("statut_suivi.suite_engagee"))
        expect(ligne).to have_checked_field("batch_action_item_#{beneficiaire.id}",
                                            visible: :all)
      end
      expect(page).not_to have_css(".dropdown_menu_button.disabled")

      click_link I18n.t("admin.beneficiaires.selection.voir_tous")
      expect(page).to have_content(non_coche.code_beneficiaire)
      expect(page).not_to have_css("input.batch-actions-resource-selection:checked",
                                   visible: :all)
    end
  end
end
