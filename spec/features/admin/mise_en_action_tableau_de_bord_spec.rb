require "rails_helper"

describe "Dashboard - Suivi des bénéficiaires", type: :feature do
  let!(:ma_structure) { create :structure_locale, :avec_admin }
  let!(:compte) { create :compte_superadmin, structure: ma_structure, cgu_acceptees: true }
  let!(:campagne) { create :campagne, compte: compte }
  let!(:beneficiaire) { create :beneficiaire, nom: "Dupont" }
  let!(:evaluation_a_suivre) do
    create :evaluation, :eva,
           synthese_competences_de_base: :illettrisme_potentiel,
           completude: "complete",
           campagne: campagne,
           beneficiaire: beneficiaire
  end

  before do
    Bullet.enable = false
    connecte(compte)
  end

  after { Bullet.enable = true }

  context "quand il y a une évaluation à renseigner" do
    it "affiche le titre de la section" do
      visit admin_path
      expect(page).to have_content(I18n.t("admin.dashboard.mise_en_action.avec_evaluations.titre"))
    end

    it "affiche le nom du bénéficiaire avec les 3 boutons de réponse" do
      visit admin_path
      expect(page).to have_content("Dupont")
      expect(page).to have_button(
        I18n.t("admin.dashboard.mise_en_action.avec_evaluations.bouton_oui")
      )
      expect(page).to have_button(
        I18n.t("admin.dashboard.mise_en_action.avec_evaluations.bouton_non")
      )
      expect(page).to have_button(
        I18n.t("admin.dashboard.mise_en_action.avec_evaluations.bouton_pas_encore")
      )
    end

    it "propose un lien vers toutes les évaluations illettrisme potentiel" do
      visit admin_path
      expect(page).to have_link(
        I18n.t("admin.dashboard.mise_en_action.avec_evaluations.voir_tout"),
        href: admin_evaluations_eva_path(scope: :illettrisme_potentiel)
      )
    end

    context "quand on répond Oui" do
      it "enregistre la réponse et affiche le message tout est à jour" do
        visit admin_path
        click_button I18n.t("admin.dashboard.mise_en_action.avec_evaluations.bouton_oui")
        expect(evaluation_a_suivre.reload.mise_en_action.effectuee).to be(true)
        message = I18n.t("admin.dashboard.mise_en_action.sans_evaluations.message")
        expect(page).to have_content(message, normalize_ws: true)
      end
    end

    context "quand on répond Non" do
      it "enregistre la réponse et affiche le message tout est à jour" do
        visit admin_path
        click_button I18n.t("admin.dashboard.mise_en_action.avec_evaluations.bouton_non")
        expect(evaluation_a_suivre.reload.mise_en_action.effectuee).to be(false)
        message = I18n.t("admin.dashboard.mise_en_action.sans_evaluations.message")
        expect(page).to have_content(message, normalize_ws: true)
      end
    end

    context "quand on répond Pas encore" do
      it "enregistre la réponse et remet l'évaluation en fin de file" do
        visit admin_path
        click_button I18n.t("admin.dashboard.mise_en_action.avec_evaluations.bouton_pas_encore")
        expect(evaluation_a_suivre.reload.mise_en_action.effectuee).to be_nil
        expect(evaluation_a_suivre.reload.mise_en_action.repondue_le).not_to be_nil
        expect(page).to have_content(
          I18n.t("admin.dashboard.mise_en_action.avec_evaluations.titre")
        )
      end
    end
  end

  context "quand il n'y a pas d'évaluation à renseigner" do
    before do
      evaluation_a_suivre.enregistre_mise_en_action(true)
    end

    it "affiche le message tout est à jour" do
      visit admin_path
      message = I18n.t("admin.dashboard.mise_en_action.sans_evaluations.message")
      expect(page).to have_content(message, normalize_ws: true)
    end
  end
end
