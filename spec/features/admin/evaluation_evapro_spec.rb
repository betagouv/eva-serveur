require 'rails_helper'

describe 'Admin - EvaluationEvapro', type: :feature do
  before { connecte(mon_compte)  }

  let(:role) { 'superadmin' }
  let(:mon_compte) { create :compte, role: role }
  let(:campagne_evapro) { create(:campagne, :avec_parcours_evapro, compte: mon_compte) }
  let(:evaluation_evapro) do
    EvaluationEvapro.create!(campagne: campagne_evapro,
                             beneficiaire: create(:beneficiaire),
                             debutee_le: 1.hour.ago)
  end

  describe "#index" do
    before do
      Bullet.enable = false
      evaluation_evapro
    end

    after { Bullet.enable = true }

    it "affiche l'en-tête du DSFR à la place de la barre de titre d'ActiveAdmin" do
      visit admin_evaluations_evapro_path

      expect(page).to have_css("nav.fr-breadcrumb")
      expect(page).to have_css("h1", text: EvaluationEvapro.model_name.human(count: 2))
      expect(page).not_to have_css("#title_bar")
      within(".entete-page__actions") do
        expect(page).to have_link(I18n.t("active_admin.action_items.telechargement_xls.libelle"),
                                  href: admin_evaluations_evapro_path(format: :xls))
      end
    end

    it "propose d'inviter des collègues à côté de l'export" do
      visit admin_evaluations_evapro_path

      within(".entete-page__actions") do
        expect(page).to have_button(I18n.t("admin.structures.modal_invitation.inviter"))
      end
    end

    it "rappelle l'entreprise sous le titre" do
      visit admin_evaluations_evapro_path

      expect(page).to have_css("h1 + p", text: mon_compte.structure.nom)
    end

    it "liste les évaluations dans un tableau DSFR" do
      visit admin_evaluations_evapro_path

      within("#evaluations") do
        expect(page).to have_link(evaluation_evapro.beneficiaire.nom,
                                  href: admin_evaluation_evapro_path(evaluation_evapro))
      end
    end

    it "recherche par nom du bénéficiaire" do
      autre = EvaluationEvapro.create!(campagne: campagne_evapro,
                                       beneficiaire: create(:beneficiaire, nom: "Zoé"),
                                       debutee_le: 1.hour.ago)
      visit admin_evaluations_evapro_path(q: { recherche: "zoe" })

      expect(page).to have_content(autre.beneficiaire.nom)
      expect(page).not_to have_content(evaluation_evapro.beneficiaire.nom)
    end
  end

  describe 'suppression' do
    before do
      Bullet.enable = false
      visit admin_evaluation_evapro_path(evaluation_evapro)
    end

    after { Bullet.enable = true }

    it "supprime l'évaluation et retourne sur la liste des évaluations Eva Pro" do
      url_suppression = admin_evaluation_evapro_path(evaluation_evapro)
      find("#action_items_sidebar_section a[href='#{url_suppression}']").click

      expect(evaluation_evapro.reload.deleted?).to be true
      expect(page.current_url).to eql(admin_evaluations_evapro_url)
    end
  end

  describe 'évaluation anonyme' do
    let(:evaluation_evapro) do
      EvaluationEvapro.create!(campagne: campagne_evapro,
                               beneficiaire: create(:beneficiaire, anonymise_le: Time.current),
                               debutee_le: 1.hour.ago)
    end

    before { Bullet.enable = false }

    after { Bullet.enable = true }

    it "prévient que l'évaluation est anonyme" do
      visit admin_evaluation_evapro_path(evaluation_evapro)

      expect(page).to have_content(I18n.t("admin.evaluations.evaluation_anonyme"))
    end
  end
end
