# frozen_string_literal: true

require "rails_helper"

describe AffiliationOpcoService, type: :model do
  let(:structure) { create(:structure_locale, idcc: idcc_values) }
  let(:idcc_values) { [] }
  let(:service) { described_class.new(structure) }

  # Créer les OPCOs de test avec leurs IDCC (format 4 chiffres, aligné avec l'import)
  let!(:opco_mobilite) { create(:opco, nom: "OPCO Mobilité", idcc: [ "0003", "0016" ]) }
  let!(:opco_2i) { create(:opco, nom: "OPCO 2i", idcc: [ "0018" ]) }
  let!(:opco_sante) { create(:opco, nom: "OPCO Santé", idcc: [ "0029" ]) }
  let!(:opco_commerce) { create(:opco, nom: "OPCO Commerce", idcc: [ "0043" ]) }

  describe "#affilie_opcos" do
    context "quand la structure a déjà un OPCO" do
      before do
        structure.update!(opco: opco_mobilite)
      end

      it "ne modifie pas l'OPCO (choix utilisateur conservé)" do
        structure.update_columns(idcc: [ "3", "18" ]) # 2 autres OPCOs possibles

        expect { service.affilie_opcos }.not_to change { structure.reload.opco_id }
        expect(structure.opco).to eq(opco_mobilite)
      end
    end

    context "quand la structure a un seul OPCO trouvé par IDCC" do
      let(:idcc_values) { [ "3" ] }

      before do
        structure.update_columns(idcc: idcc_values)
      end

      it "pré-remplit cet OPCO" do
        service.affilie_opcos

        expect(structure.opco_id).to eq(opco_mobilite.id)
        structure.save!
        structure.reload
        expect(structure.opco).to eq(opco_mobilite)
      end

      it "n'ajoute pas de doublon si appelé plusieurs fois" do
        service.affilie_opcos
        service.affilie_opcos

        expect(structure.opco_id).to eq(opco_mobilite.id)
        structure.save!
        structure.reload
        expect(structure.opco).to eq(opco_mobilite)
      end
    end

    context "quand la structure a plusieurs IDCC pointant vers le même OPCO" do
      let(:idcc_values) { [ "3", "16" ] } # Les deux pointent vers OPCO Mobilité

      before do
        structure.update_columns(idcc: idcc_values)
      end

      it "affilie cet unique OPCO (pré-remplissage)" do
        service.affilie_opcos
        structure.save!

        structure.reload
        expect(structure.opco).to eq(opco_mobilite)
      end
    end

    context "quand la structure a deux IDCC correspondant à deux OPCOs différents" do
      let(:idcc_values) { [ "3", "18" ] }

      before do
        structure.update_columns(idcc: idcc_values)
      end

      it "n'attache aucun OPCO (l'utilisateur choisira au sélect)" do
        service.affilie_opcos

        structure.reload
        expect(structure.opco).to be_nil
      end
    end

    context "quand la structure a trois IDCC différents" do
      let(:idcc_values) { [ "3", "18", "29" ] }

      before do
        structure.update_columns(idcc: idcc_values)
      end

      it "n'attache aucun OPCO (l'utilisateur choisira au sélect)" do
        service.affilie_opcos

        structure.reload
        expect(structure.opco).to be_nil
      end
    end

    context "quand la structure n'a pas d'IDCC" do
      let(:idcc_values) { [] }

      it "n'affilie aucun OPCO" do
        service.affilie_opcos

        structure.reload
        expect(structure.opco).to be_nil
      end
    end

    context "quand la structure a un IDCC nil" do
      let(:idcc_values) { nil }

      it "n'affilie aucun OPCO" do
        service.affilie_opcos

        expect(structure.opco_id).to be_nil
      end
    end

    context "quand la structure a un IDCC inexistant" do
      let(:idcc_values) { [ "99999" ] }

      it "n'affilie aucun OPCO" do
        service.affilie_opcos

        structure.reload
        expect(structure.opco).to be_nil
      end
    end
  end

  describe "#normalise_idcc (private)" do
    it "convertit un entier en string et padde à 4 chiffres" do
      idcc_normalise = service.send(:normalise_idcc, 3)
      expect(idcc_normalise).to eq("0003")
    end

    it "convertit une string numérique et padde à 4 chiffres" do
      idcc_normalise = service.send(:normalise_idcc, "3")
      expect(idcc_normalise).to eq("0003")
    end

    it "supprime les espaces et padde à 4 chiffres" do
      idcc_normalise = service.send(:normalise_idcc, " 3 ")
      expect(idcc_normalise).to eq("0003")
    end

    it "préserve un IDCC 0843 (4 chiffres) pour la correspondance avec l'import" do
      idcc_normalise = service.send(:normalise_idcc, "843")
      expect(idcc_normalise).to eq("0843")
    end

    it "retourne nil pour nil" do
      idcc_normalise = service.send(:normalise_idcc, nil)
      expect(idcc_normalise).to be_nil
    end

    it "retourne nil pour une string vide" do
      idcc_normalise = service.send(:normalise_idcc, "")
      expect(idcc_normalise).to be_nil
    end
  end
end
