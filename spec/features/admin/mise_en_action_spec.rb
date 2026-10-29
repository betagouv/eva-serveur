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
    before { visit admin_evaluation_eva_path(evaluation) }

    it "ouvre le questionnaire de remédiation quand on répond Oui" do
      within(".card__banner--illettrisme") { click_button "Oui" }

      expect(page).to have_css(".questions-remediation", visible: :visible)
      expect(page).to have_css(".questions-difficulte", visible: :hidden)
      expect(mise_en_action.effectuee).to be(true)
    end

    it "ouvre le questionnaire de difficulté quand on répond Non" do
      within(".card__banner--illettrisme") { click_button "Non" }

      expect(page).to have_css(".questions-difficulte", visible: :visible)
      expect(page).to have_css(".questions-remediation", visible: :hidden)
      expect(mise_en_action.effectuee).to be(false)
    end

    it "affiche la remédiation choisie une fois validée" do
      within(".card__banner--illettrisme") do
        click_button "Oui"
        within(".questions-remediation") do
          find("label", text: "Formation métier / qualifiante").click
          click_button "Valider"
        end

        expect(page).to have_css(".questions-remediation", visible: :hidden)
        expect(page).to have_content("Oui vous avez trouvé une solution")
        expect(page).to have_css(".qualification-mise-en-action",
                                 text: "Formation métier / qualifiante")
      end
      expect(page).to have_css(".card__banner--illettrisme.card__banner--succes")
      expect(mise_en_action.reload.remediation).to eq("formation_metier")
    end

    it "n'affiche pas de qualification quand on ignore le questionnaire" do
      within(".card__banner--illettrisme") do
        click_button "Oui"
        within(".questions-remediation") { click_button "Ignorer" }

        expect(page).to have_css(".questions-remediation", visible: :hidden)
        expect(page).to have_content("Oui vous avez trouvé une solution")
        expect(page).to have_no_css(".qualification-mise-en-action", visible: :visible)
      end
      expect(page).to have_css(".card__banner--illettrisme.card__banner--succes")
      expect(mise_en_action.reload.remediation).to eq("indetermine")
    end

    it "affiche la difficulté choisie une fois validée" do
      within(".card__banner--illettrisme") do
        click_button "Non"
        within(".questions-difficulte") do
          find("label", text: "Accompagnement spécifique nécessaire").click
          click_button "Valider"
        end

        expect(page).to have_css(".questions-difficulte", visible: :hidden)
        expect(page).to have_content("Non vous n'avez pas trouvé de solution")
        expect(page).to have_css("[data-reponse='false'] .qualification-mise-en-action",
                                 text: "Accompagnement spécifique nécessaire")
      end
      expect(mise_en_action.reload.difficulte).to eq("accompagnement_necessaire")
    end
  end

  describe "sur le détail d'une évaluation avec une remédiation" do
    before do
      create :mise_en_action, evaluation: evaluation, effectuee: true,
                              remediation: "formation_metier"
      visit admin_evaluation_eva_path(evaluation)
    end

    it "propose de nouveau Oui et Non quand on modifie la réponse" do
      expect(page).to have_css(".card__banner--illettrisme.card__banner--succes")

      within(".card__banner--illettrisme") { click_link "Modifier votre réponse" }

      expect(page).to have_button("Oui")
      expect(page).to have_button("Non")
      expect(page).to have_css(".card__banner--illettrisme.card__banner--en-attente")
    end

    it "affiche la nouvelle qualification quand on change de réponse" do
      within(".card__banner--illettrisme") do
        click_link "Modifier votre réponse"
        click_button "Non"
        within(".questions-difficulte") do
          find("label", text: "Accompagnement spécifique nécessaire").click
          click_button "Valider"
        end

        expect(page).to have_content("Non vous n'avez pas trouvé de solution")
        expect(page).to have_css("[data-reponse='false'] .qualification-mise-en-action",
                                 text: "Accompagnement spécifique nécessaire")
        expect(page).to have_no_content("Oui vous avez trouvé une solution")
      end
      expect(page).to have_css(".card__banner--illettrisme.card__banner--succes")
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
end
