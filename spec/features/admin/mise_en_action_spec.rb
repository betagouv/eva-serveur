require "rails_helper"

describe "Admin - Mise en action", :js, type: :feature do
  let(:mon_compte) { create :compte, role: "admin" }
  let(:ma_campagne) { create :campagne, compte: mon_compte }
  let!(:evaluation) do
    create :evaluation, :eva, campagne: ma_campagne,
                              synthese_competences_de_base: :illettrisme_potentiel,
                              completude: "complete"
  end
  let(:mise_en_action) { MiseEnAction.find_by(evaluation_id: evaluation.id) }

  before do
    Bullet.enable = false
    connecte(mon_compte)
    # En mode JS, la connexion n'est pas terminée au retour de connecte
    page.assert_current_path(admin_dashboard_path)
  end

  after { Bullet.enable = true }

  describe "sur le détail d'une évaluation" do
    let(:formation_metier) do
      I18n.t("activerecord.attributes.mise_en_action.remediation.formation_metier")
    end
    let(:accompagnement_necessaire) do
      I18n.t("activerecord.attributes.mise_en_action.difficulte.accompagnement_necessaire")
    end

    before { visit admin_evaluation_eva_path(evaluation) }

    it "remplace la question par le choix du type d'aide quand on répond Oui" do
      within(".card__banner--illettrisme") { click_button "Oui" }

      expect(page).to have_css(".questions-remediation", visible: :visible,
                               text: I18n.t("qualification_mise_en_action.titre_remediation"))
      expect(page).to have_css(".questions-difficulte", visible: :hidden)
      expect(page).to have_no_button("Oui")
      expect(mise_en_action.effectuee).to be(true)
    end

    it "remplace la question par le choix de la raison quand on répond Non" do
      within(".card__banner--illettrisme") { click_button "Non" }

      expect(page).to have_css(".questions-difficulte", visible: :visible,
                               text: I18n.t("qualification_mise_en_action.titre_difficulte"))
      expect(page).to have_css(".questions-remediation", visible: :hidden)
      expect(page).to have_no_button("Non")
      expect(mise_en_action.effectuee).to be(false)
    end

    it "enregistre le type d'aide dès qu'on le choisit" do
      within(".card__banner--illettrisme") do
        click_button "Oui"
        within(".questions-remediation") { click_button formation_metier }

        expect(page).to have_css(".questions-remediation", visible: :hidden)
        expect(page).to have_content(I18n.t("reponse_mise_en_action.titre_true"))
        expect(page).to have_css("[data-reponse='true'] .tag", text: formation_metier)
      end
      expect(mise_en_action.reload.remediation).to eq("formation_metier")
    end

    it "enregistre la raison dès qu'on la choisit" do
      within(".card__banner--illettrisme") do
        click_button "Non"
        within(".questions-difficulte") { click_button accompagnement_necessaire }

        expect(page).to have_css(".questions-difficulte", visible: :hidden)
        expect(page).to have_content(I18n.t("reponse_mise_en_action.titre_false"))
        expect(page).to have_css("[data-reponse='false'] .tag", text: accompagnement_necessaire)
      end
      expect(mise_en_action.reload.difficulte).to eq("accompagnement_necessaire")
    end

    it "repose la question quand on change de réponse avant de choisir" do
      within(".card__banner--illettrisme") do
        click_button "Oui"
        within(".questions-remediation") do
          click_link I18n.t("qualification_mise_en_action.changer")
        end

        expect(page).to have_button("Oui")
        expect(page).to have_button("Non")
        expect(page).to have_css(".questions-remediation", visible: :hidden)
      end
    end
  end

  describe "sur le détail d'une évaluation avec une remédiation" do
    let(:accompagnement_necessaire) do
      I18n.t("activerecord.attributes.mise_en_action.difficulte.accompagnement_necessaire")
    end

    before do
      create :mise_en_action, evaluation: evaluation, effectuee: true,
                              remediation: "formation_metier"
      visit admin_evaluation_eva_path(evaluation)
    end

    it "propose de nouveau Oui et Non quand on modifie la réponse" do
      within(".card__banner--illettrisme") { click_link I18n.t("reponse_mise_en_action.modifier") }

      expect(page).to have_button("Oui")
      expect(page).to have_button("Non")
    end

    it "affiche la nouvelle qualification quand on change de réponse" do
      within(".card__banner--illettrisme") do
        click_link I18n.t("reponse_mise_en_action.modifier")
        click_button "Non"
        within(".questions-difficulte") { click_button accompagnement_necessaire }

        expect(page).to have_content(I18n.t("reponse_mise_en_action.titre_false"))
        expect(page).to have_css("[data-reponse='false'] .tag", text: accompagnement_necessaire)
        expect(page).to have_no_content(I18n.t("reponse_mise_en_action.titre_true"))
      end
    end
  end

  describe "sur le tableau de bord" do
    before { visit admin_dashboard_path }

    it "ouvre le questionnaire de remédiation dans la carte quand on répond Oui" do
      within("li[id='#{evaluation.id}']") do
        click_button "Oui"

        expect(page).to have_css(".carte--deroulee")
        expect(page).to have_css(".questions-remediation", visible: :visible)
        expect(page).to have_css(".questions-difficulte", visible: :hidden)
      end
      expect(mise_en_action.effectuee).to be(true)
    end

    it "referme la carte une fois la remédiation validée" do
      within("li[id='#{evaluation.id}']") do
        click_button "Oui"
        within(".questions-remediation") do
          find("label", text: "Formation métier / qualifiante").click
          click_button "Valider"
        end

        expect(page).to have_no_css(".carte--deroulee")
        expect(page).to have_content("Oui vous avez trouvé une solution")
        expect(page).to have_no_css(".mise-en-action .tag", visible: :all)
      end
      expect(mise_en_action.reload.remediation).to eq("formation_metier")
    end
  end

  describe "quand l'option « je ne sais pas » est active" do
    let(:revue_prevue) { "Revue prévue le #{I18n.l(Date.current + 7)}" }

    before { allow(MiseEnAction).to receive(:je_ne_sais_pas_actif?).and_return(true) }

    describe "sur le détail d'une évaluation" do
      before { visit admin_evaluation_eva_path(evaluation) }

      it "affiche la date de revue sans ouvrir de questionnaire " \
         "quand on répond « je ne sais pas »" do
        within(".card__banner--illettrisme") do
          click_button "Je ne sais pas"

          expect(page).to have_css("[data-reponse='je_ne_sais_pas'] .tag", text: revue_prevue)
          expect(page).to have_css(".qcm", visible: :hidden, count: 2)
        end
        expect(mise_en_action.motif).to eq("action_prevue")
      end

      it "propose de nouveau les réponses quand on modifie « je ne sais pas »" do
        within(".card__banner--illettrisme") do
          click_button "Je ne sais pas"
          click_link I18n.t("reponse_mise_en_action.modifier")

          expect(page).to have_button("Oui")
          expect(page).to have_button("Non")
          expect(page).to have_button("Je ne sais pas")
        end
      end
    end

    describe "sur le tableau de bord" do
      before { visit admin_dashboard_path }

      it "affiche la réponse sans dérouler la carte quand on répond « je ne sais pas »" do
        within("li[id='#{evaluation.id}']") do
          click_button "Je ne sais pas"

          expect(page).to have_css("div[data-reponse='je_ne_sais_pas']", text: "Je ne sais pas")
          expect(page).to have_no_css(".carte--deroulee")
          expect(page).to have_css(".qcm", visible: :hidden, count: 2)
        end
        expect(mise_en_action.effectuee).to be_nil
      end
    end
  end
end
