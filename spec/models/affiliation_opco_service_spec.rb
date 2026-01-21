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
    context "quand la structure a des IDCC valides" do
      let(:idcc_values) { [ "3", "18" ] }

      before do
        structure.update_columns(idcc: idcc_values)
      end

      it "affilie les OPCOs correspondants" do
        expect do
          service.affilie_opcos
        end.to change(StructureOpco, :count).by(2)

        structure.reload
        expect(structure.opcos.to_a).to contain_exactly(opco_mobilite, opco_2i)
      end

      it "n'ajoute pas de doublons si appelé plusieurs fois" do
        service.affilie_opcos
        service.affilie_opcos

        structure.reload
        expect(structure.opcos.count).to eq(2)
        expect(structure.opcos.to_a).to contain_exactly(opco_mobilite, opco_2i)
      end
    end

    context "quand la structure a plusieurs IDCC pointant vers le même OPCO" do
      let(:idcc_values) { [ "3", "16" ] } # Les deux pointent vers OPCO Mobilité

      before do
        structure.update_columns(idcc: idcc_values)
      end

      it "n'affilie l'OPCO qu'une seule fois" do
        service.affilie_opcos

        structure.reload
        expect(structure.opcos.count).to eq(1)
        expect(structure.opcos.first).to eq(opco_mobilite)
      end
    end

    context "quand la structure a trois IDCC différents" do
      let(:idcc_values) { [ "3", "18", "29" ] }

      before do
        structure.update_columns(idcc: idcc_values)
      end

      it "affilie les trois OPCOs correspondants" do
        service.affilie_opcos

        structure.reload
        expect(structure.opcos.count).to eq(3)
        expect(structure.opcos.to_a).to contain_exactly(opco_mobilite, opco_2i, opco_sante)
      end
    end

    context "quand la structure n'a pas d'IDCC" do
      let(:idcc_values) { [] }

      it "n'affilie aucun OPCO" do
        expect do
          service.affilie_opcos
        end.not_to change(StructureOpco, :count)

        structure.reload
        expect(structure.opcos).to be_empty
      end
    end

    context "quand la structure a un IDCC nil" do
      let(:idcc_values) { nil }

      it "n'affilie aucun OPCO" do
        expect do
          service.affilie_opcos
        end.not_to change(StructureOpco, :count)
      end
    end

    context "quand la structure a un IDCC inexistant" do
      let(:idcc_values) { [ "99999" ] }

      it "n'affilie aucun OPCO" do
        expect do
          service.affilie_opcos
        end.not_to change(StructureOpco, :count)

        structure.reload
        expect(structure.opcos).to be_empty
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
