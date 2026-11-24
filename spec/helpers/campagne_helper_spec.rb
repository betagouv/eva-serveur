require "rails_helper"

describe CampagneHelper, type: :helper do
  describe "#actions_campagne" do
    it "propose de voir, modifier et supprimer la campagne, avec ses traductions" do
      actions = helper.actions_campagne

      expect(actions.pluck(:type)).to eq %i[read edit destroy]
      expect(actions.pluck(:url)).to eq %i[admin_campagne_path edit_admin_campagne_path
                                           admin_campagne_path]
      expect(actions.pluck(:label)).to eq [ I18n.t("admin.campagnes.index.voir"),
                                            I18n.t("admin.campagnes.index.modifier"),
                                            I18n.t("admin.campagnes.index.supprimer") ]
    end

    it "demande confirmation avant de supprimer" do
      expect(helper.actions_campagne.last).to include(
        method: :delete,
        data: { confirm: I18n.t("admin.campagnes.index.confirmation_suppression") }
      )
    end
  end
end
