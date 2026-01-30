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

  describe "#opcos_possibles" do
    context "quand la structure a des IDCC valides" do
      let(:idcc_values) { [ "3", "18" ] }

      before do
        structure.update_columns(idcc: idcc_values)
      end

      it "retourne les OPCOs correspondants" do
        opcos = service.opcos_possibles

        expect(opcos.to_a).to contain_exactly(opco_mobilite, opco_2i)
      end
    end

    context "quand la structure n'a pas d'IDCC" do
      let(:idcc_values) { [] }

      it "retourne une liste vide" do
        expect(service.opcos_possibles.to_a).to eq([])
      end
    end
  end

  describe "#affilie_opcos" do
    context "quand un seul OPCO est possible et la structure n'a pas encore d'OPCO" do
      let(:idcc_values) { [ "3" ] }

      before do
        structure.update_columns(idcc: idcc_values)
      end

      it "assigne cet OPCO à la structure" do
        service.affilie_opcos

        structure.reload
        expect(structure.opco_id).to eq(opco_mobilite.id)
        expect(structure.opco).to eq(opco_mobilite)
      end

      it "ne change rien si la structure a déjà un OPCO" do
        structure.update!(opco: opco_commerce)
        service.affilie_opcos

        structure.reload
        expect(structure.opco).to eq(opco_commerce)
      end
    end

    context "quand plusieurs OPCOs sont possibles" do
      let(:idcc_values) { [ "3", "18" ] }

      before do
        structure.update_columns(idcc: idcc_values)
      end

      it "n'assigne aucun OPCO (l'utilisateur choisit dans le formulaire)" do
        service.affilie_opcos

        structure.reload
        expect(structure.opco_id).to be_nil
        expect(structure.opco).to be_nil
      end
    end

    context "quand la structure a plusieurs IDCC pointant vers le même OPCO" do
      let(:idcc_values) { [ "3", "16" ] } # Les deux pointent vers OPCO Mobilité

      before do
        structure.update_columns(idcc: idcc_values)
      end

      it "assigne cet OPCO une seule fois" do
        service.affilie_opcos

        structure.reload
        expect(structure.opco).to eq(opco_mobilite)
      end
    end

    context "quand la structure n'a pas d'IDCC" do
      let(:idcc_values) { [] }

      it "n'assigne aucun OPCO" do
        service.affilie_opcos

        structure.reload
        expect(structure.opco).to be_nil
      end
    end

    context "quand la structure a un IDCC nil" do
      let(:idcc_values) { nil }

      it "n'assigne aucun OPCO" do
        service.affilie_opcos

        structure.reload
        expect(structure.opco).to be_nil
      end
    end

    context "quand la structure a un IDCC inexistant" do
      let(:idcc_values) { [ "99999" ] }

      it "n'assigne aucun OPCO" do
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
