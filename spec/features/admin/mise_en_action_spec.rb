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
  let(:precisez) { I18n.t("activerecord.attributes.mise_en_action.precision_autre") }
  let(:enregistrer) { I18n.t("qualification_mise_en_action.enregistrer") }

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
        expect(page).to have_css(
          "[data-reponse='true'] .mise-en-action-repondue__date",
          text: I18n.t("reponse_mise_en_action.repondue_le",
                       date: I18n.l(Date.current, format: :short))
        )
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
          click_link I18n.t("qualification_mise_en_action.modifier")
        end

        expect(page).to have_button("Oui")
        expect(page).to have_button("Non")
        expect(page).to have_css(".questions-remediation", visible: :hidden)
      end
    end
  end

  describe "sur le détail d'une évaluation, réponse « Autre »" do
    let(:autre) { I18n.t("activerecord.attributes.mise_en_action.remediation.autre") }
    let(:formation_metier) do
      I18n.t("activerecord.attributes.mise_en_action.remediation.formation_metier")
    end

    before do
      visit admin_evaluation_eva_path(evaluation)
      within(".card__banner--illettrisme") { click_button "Oui" }
    end

    it "ouvre « Précisez » sans rien enregistrer" do
      within(".questions-remediation") do
        click_button autre

        expect(page).to have_css("button[aria-pressed='true']", text: autre)
        expect(page).to have_field(precisez)
        expect(page).to have_button(enregistrer)
        expect(page).to have_field(precisez, focused: true)
      end
      expect(mise_en_action.reload.remediation).to be_nil
    end

    it "refuse d'enregistrer une précision vide ou faite d'espaces" do
      message = I18n.t("activerecord.errors.models.mise_en_action.attributes" \
                       ".precision_autre.blank_remediation")
      within(".questions-remediation") do
        click_button autre
        click_button enregistrer

        expect(page).to have_css(".fr-message--error", text: message)

        fill_in precisez, with: "   "
        click_button enregistrer

        expect(page).to have_css(".fr-message--error", text: message)
        expect(page).to have_field(precisez, focused: true)
      end
      expect(mise_en_action.reload.remediation).to be_nil
    end

    it "n'affiche plus l'erreur une fois la précision enregistrée" do
      within(".card__banner--illettrisme") do
        within(".questions-remediation") do
          click_button autre
          click_button enregistrer
          fill_in precisez, with: "atelier numérique"
          click_button enregistrer
        end
        expect(page).to have_css("div[data-reponse='true']",
                                 text: I18n.t("reponse_mise_en_action.autre",
                                              precision: "atelier numérique"))
        click_link I18n.t("reponse_mise_en_action.modifier")
        click_button "Oui"

        within(".questions-remediation") do
          expect(page).to have_field(precisez, with: "atelier numérique")
          expect(page).to have_no_css(".fr-message--error")
        end
      end
    end

    it "enregistre « Autre » avec sa précision et l'affiche" do
      within(".card__banner--illettrisme") do
        within(".questions-remediation") do
          click_button autre
          fill_in precisez, with: "atelier numérique"
          click_button enregistrer
        end

        expect(page).to have_css(".questions-remediation", visible: :hidden)
        expect(page).to have_css("[data-reponse='true']",
                                 text: I18n.t("reponse_mise_en_action.autre",
                                              precision: "atelier numérique"))
        expect(page).to have_css(
          "[data-reponse='true'] .mise-en-action-repondue__date",
          text: I18n.t("reponse_mise_en_action.repondue_le",
                       date: I18n.l(Date.current, format: :short))
        )
      end
      expect(mise_en_action.reload).to have_attributes(remediation: "autre",
                                                       precision_autre: "atelier numérique")
    end

    it "abandonne la précision quand on choisit un autre type d'aide" do
      within(".questions-remediation") do
        click_button autre
        fill_in precisez, with: "atelier numérique"
        click_button formation_metier
      end

      expect(page).to have_css("[data-reponse='true'] .tag", text: formation_metier)
      expect(mise_en_action.reload).to have_attributes(remediation: "formation_metier",
                                                       precision_autre: nil)
    end

    it "referme « Précisez » sans rien enregistrer quand on reclique sur « Autre »" do
      within(".questions-remediation") do
        click_button autre
        click_button autre

        expect(page).to have_css("button[aria-pressed='false']", text: autre)
        expect(page).to have_no_field(precisez)
        expect(page).to have_no_button(enregistrer)
      end
      expect(mise_en_action.reload.remediation).to be_nil
    end
  end

  describe "sur le détail d'une évaluation avec une réponse « Autre »" do
    before do
      create :mise_en_action, evaluation: evaluation, effectuee: true, remediation: "autre",
                              precision_autre: "atelier numérique"
      visit admin_evaluation_eva_path(evaluation)
    end

    it "retrouve « Autre » et sa précision quand on modifie la réponse" do
      within(".card__banner--illettrisme") do
        click_link I18n.t("reponse_mise_en_action.modifier")
        click_button "Oui"

        within(".questions-remediation") do
          expect(page).to have_css("button[aria-pressed='true']",
                                   text: I18n.t("activerecord.attributes.mise_en_action" \
                                                ".remediation.autre"))
          expect(page).to have_field(precisez, with: "atelier numérique")
        end
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
        expect(page).to have_no_css(".qualification-mise-en-action", visible: :all)
      end
      expect(mise_en_action.reload.remediation).to eq("formation_metier")
    end
  end

  describe "sur le tableau de bord, réponse « Autre »" do
    let(:autre) { I18n.t("activerecord.attributes.mise_en_action.remediation.autre") }
    let(:formation_metier) do
      I18n.t("activerecord.attributes.mise_en_action.remediation.formation_metier")
    end

    before do
      visit admin_dashboard_path
      within("li[id='#{evaluation.id}']") { click_button "Oui" }
    end

    it "ouvre « Précisez » sans rien enregistrer" do
      within("li[id='#{evaluation.id}'] .questions-remediation") do
        expect(page).to have_no_field(precisez)

        find("label", text: autre).click

        expect(page).to have_field(precisez, focused: true)
      end
      expect(mise_en_action.reload.remediation).to be_nil
    end

    it "n'active « Valider » qu'une fois « Précisez » rempli" do
      within("li[id='#{evaluation.id}'] .questions-remediation") do
        find("label", text: autre).click

        expect(page).to have_button(I18n.t("qcm.action_valider"), disabled: true)

        fill_in precisez, with: "   "

        expect(page).to have_button(I18n.t("qcm.action_valider"), disabled: true)

        fill_in precisez, with: "atelier numérique"

        expect(page).to have_button(I18n.t("qcm.action_valider"), disabled: false)
      end
    end

    it "enregistre « Autre » avec sa précision et referme la carte" do
      within("li[id='#{evaluation.id}']") do
        within(".questions-remediation") do
          find("label", text: autre).click
          fill_in precisez, with: "atelier numérique"
          click_button I18n.t("qcm.action_valider")
        end

        expect(page).to have_no_css(".carte--deroulee")
      end
      expect(mise_en_action.reload).to have_attributes(remediation: "autre",
                                                       precision_autre: "atelier numérique")
    end

    it "abandonne la précision quand on choisit un autre type d'aide" do
      within("li[id='#{evaluation.id}'] .questions-remediation") do
        find("label", text: autre).click
        fill_in precisez, with: "atelier numérique"
        find("label", text: formation_metier).click

        expect(page).to have_no_field(precisez)

        click_button I18n.t("qcm.action_valider")
      end

      expect(page).to have_no_css(".carte--deroulee")
      expect(mise_en_action.reload).to have_attributes(remediation: "formation_metier",
                                                       precision_autre: nil)
    end

    it "retrouve « Autre » et sa précision quand on modifie la réponse" do
      within("li[id='#{evaluation.id}']") do
        within(".questions-remediation") do
          find("label", text: autre).click
          fill_in precisez, with: "atelier numérique"
          click_button I18n.t("qcm.action_valider")
        end
        click_link I18n.t("components.modification_mise_en_action.modifier_reponse")
        click_button "Oui"

        within(".questions-remediation") do
          expect(find("input[value='autre']", visible: :all)).to be_checked
          expect(page).to have_field(precisez, with: "atelier numérique")
        end
      end
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
