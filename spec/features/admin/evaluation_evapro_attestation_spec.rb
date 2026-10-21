require "rails_helper"

describe "Admin - Attestation de passation Evapro", type: :feature do
  before do
    Bullet.enable = false
    connecte(compte)
  end

  after { Bullet.enable = true }

  let(:structure_evapro) { create(:structure_locale, usage: AvecUsage::USAGE_EVAPRO) }
  let(:compte) { create :compte, role: "admin", structure: structure_evapro }
  let(:campagne) { create(:campagne, :avec_parcours_evapro, compte: compte) }
  let(:beneficiaire) { create(:beneficiaire, compte: compte) }
  let(:evaluation) do
    create(:evaluation, :evapro, campagne: campagne, beneficiaire: beneficiaire,
                                 completude: completude)
  end
  let(:libelle_bouton) do
    I18n.t("admin.evaluations_evapro.restitution_globale.bouton_attestation")
  end

  context "quand la fonctionnalité est active" do
    before { allow(AttestationPassation).to receive(:active?).and_return(true) }

    context "quand le questionnaire est complet" do
      let(:completude) { :complete }

      it "affiche le bouton de téléchargement de l'attestation" do
        visit admin_evaluation_evapro_path(evaluation)

        expect(page).to have_link(libelle_bouton)
      end
    end

    context "quand le questionnaire est incomplet" do
      let(:completude) { :incomplete }

      it "n'affiche pas le bouton" do
        visit admin_evaluation_evapro_path(evaluation)

        expect(page).to have_no_link(libelle_bouton)
      end
    end

    context "quand le compte a créé la campagne sans avoir passé le diagnostic" do
      let(:completude) { :complete }
      let(:personne_evaluee) do
        create :compte, role: "conseiller", structure: structure_evapro
      end
      let(:beneficiaire) { create(:beneficiaire, compte: personne_evaluee) }

      it "affiche le bouton, comme celui de l'export" do
        visit admin_evaluation_evapro_path(evaluation)

        expect(page).to have_link(libelle_bouton)
      end
    end
  end

  context "quand la fonctionnalité est inactive" do
    let(:completude) { :complete }

    before { allow(AttestationPassation).to receive(:active?).and_return(false) }

    it "n'affiche pas le bouton" do
      visit admin_evaluation_evapro_path(evaluation)

      expect(page).to have_no_link(libelle_bouton)
    end
  end
end
