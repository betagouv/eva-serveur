require "rails_helper"

describe Admin::BeneficiaireHelper, type: :helper do
  describe "#statut_suivi_beneficiaire" do
    let(:beneficiaire_a_renseigner) { create :beneficiaire }
    let(:beneficiaire_non_concerne) { create :beneficiaire }
    let(:beneficiaires) { [ beneficiaire_a_renseigner, beneficiaire_non_concerne ] }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("DATE_STATUT_SUIVI").and_return("2020-01-01")
      create :evaluation, :eva, beneficiaire: beneficiaire_a_renseigner,
                                synthese_competences_de_base: :illettrisme_potentiel,
                                completude: "complete"
      create :evaluation, :eva, beneficiaire: beneficiaire_non_concerne,
                                synthese_competences_de_base: :socle_clea
    end

    it "affiche le badge du statut du bénéficiaire" do
      expect(Capybara.string(helper.statut_suivi_beneficiaire(beneficiaire_a_renseigner,
                                                              beneficiaires)))
        .to have_css(".fr-badge", text: "À renseigner")
    end

    it "affiche un tiret pour un bénéficiaire non concerné" do
      expect(Capybara.string(helper.statut_suivi_beneficiaire(beneficiaire_non_concerne,
                                                              beneficiaires)))
        .to have_css("[aria-hidden='true']", text: "-")
    end
  end

  describe "#actions_beneficiaire" do
    it "propose de voir, modifier et supprimer le bénéficiaire, avec ses traductions" do
      actions = helper.actions_beneficiaire

      expect(actions.pluck(:type)).to eq %i[read edit destroy]
      expect(actions.pluck(:url)).to eq %i[admin_beneficiaire_path edit_admin_beneficiaire_path
                                           admin_beneficiaire_path]
      expect(actions.pluck(:label)).to eq [ I18n.t("admin.beneficiaires.index.voir"),
                                            I18n.t("admin.beneficiaires.index.modifier"),
                                            I18n.t("admin.beneficiaires.index.supprimer") ]
    end

    it "demande confirmation avant de supprimer" do
      suppression = helper.actions_beneficiaire.last

      expect(suppression).to include(
        method: :delete,
        data: { confirm: I18n.t("admin.beneficiaires.index.confirmation_suppression") }
      )
    end
  end
end
