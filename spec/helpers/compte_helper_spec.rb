require "rails_helper"

describe CompteHelper do
  describe "#traduis_acces" do
    it "affiche le statut et le role pour les comptes acceptés" do
      expect(traduis_acces("acceptee", "conseiller")).to eq("Autorisé - Conseiller")
      expect(traduis_acces("acceptee", "admin")).to eq("Autorisé - Admin")
    end

    it "affiche seulement le statut pour les autres statuts" do
      expect(traduis_acces("refusee", "whatever")).to eq("Refusé")
      expect(traduis_acces("en_attente", nil)).to eq("En attente")
    end
  end

  describe "#actions_compte" do
    it "propose de voir, modifier et supprimer le compte, avec ses traductions" do
      actions = helper.actions_compte

      expect(actions.pluck(:type)).to eq %i[read edit destroy]
      expect(actions.pluck(:url)).to eq %i[admin_compte_path edit_admin_compte_path
                                           admin_compte_path]
      expect(actions.pluck(:label)).to eq [ I18n.t("admin.comptes.index.voir"),
                                            I18n.t("admin.comptes.index.modifier"),
                                            I18n.t("admin.comptes.index.supprimer") ]
    end

    it "demande confirmation avant de supprimer" do
      expect(helper.actions_compte.last).to include(
        method: :delete,
        data: { confirm: I18n.t("admin.comptes.index.confirmation_suppression") }
      )
    end
  end
end
