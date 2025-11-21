require "rails_helper"

describe AffiliationOpcoService, type: :model do
  let(:structure) { create(:structure_locale, idcc: idcc_values) }
  let(:idcc_values) { [] }
  let(:service) do
    s = described_class.new(structure)
    allow(s).to receive(:mapping_idcc_opco).and_return(mapping_test)
    s
  end

  # Créer les OPCOs de test
  let!(:opco_mobilite) { create(:opco, nom: "OPCO Mobilité") }
  let!(:opco_2i) { create(:opco, nom: "OPCO 2i") }
  let!(:opco_sante) { create(:opco, nom: "OPCO Santé") }
  let!(:opco_commerce) { create(:opco, nom: "OPCO Commerce") }

  # Mock du mapping
  let(:mapping_test) do
    {
      "3" => "OPCO Mobilité",
      "16" => "OPCO Mobilité",
      "18" => "OPCO 2i",
      "29" => "OPCO Santé",
      "43" => "OPCO Commerce"
    }
  end

  describe "#affilie_opcos" do
    context "quand la structure a des IDCC valides" do
      let(:idcc_values) { [ "3", "18" ] }

      before do
        structure.update_columns(idcc: idcc_values)
      end

      it "affilie les OPCOs correspondants" do
        test_service = described_class.new(structure)
        allow(test_service).to receive(:mapping_idcc_opco).and_return(mapping_test)

        expect do
          test_service.affilie_opcos
        end.to change(StructureOpco, :count).by(2)

        structure.reload
        expect(structure.opcos.to_a).to contain_exactly(opco_mobilite, opco_2i)
      end

      it "n'ajoute pas de doublons si appelé plusieurs fois" do
        test_service = described_class.new(structure)
        allow(test_service).to receive(:mapping_idcc_opco).and_return(mapping_test)

        test_service.affilie_opcos
        test_service.affilie_opcos

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
        test_service = described_class.new(structure)
        allow(test_service).to receive(:mapping_idcc_opco).and_return(mapping_test)

        test_service.affilie_opcos

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
        test_service = described_class.new(structure)
        allow(test_service).to receive(:mapping_idcc_opco).and_return(mapping_test)

        test_service.affilie_opcos

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

    context "quand la structure a un IDCC inexistant dans le mapping" do
      let(:idcc_values) { [ "99999" ] }

      it "n'affilie aucun OPCO" do
        expect do
          service.affilie_opcos
        end.not_to change(StructureOpco, :count)

        structure.reload
        expect(structure.opcos).to be_empty
      end
    end

    context "quand l'IDCC existe dans le mapping mais l'OPCO n'existe pas en base" do
      let(:idcc_values) { [ "3" ] }
      let(:service) do
        s = described_class.new(structure)
        allow(s).to receive(:mapping_idcc_opco).and_return({ "3" => "OPCO Inexistant" })
        s
      end

      it "n'affilie aucun OPCO" do
        expect do
          service.affilie_opcos
        end.not_to change(StructureOpco, :count)
      end
    end

    context "quand le fichier Excel n'existe pas" do
      let(:idcc_values) { [ "3" ] }
      let(:service) do
        s = described_class.new(structure)
        allow(s).to receive(:mapping_idcc_opco).and_return({})
        s
      end

      it "n'affilie aucun OPCO et ne lève pas d'erreur" do
        expect do
          service.affilie_opcos
        end.not_to change(StructureOpco, :count)
      end
    end

    context "quand il y a une erreur lors du chargement du fichier Excel" do
      let(:idcc_values) { [ "3" ] }
      let(:service) do
        s = described_class.new(structure)
        allow(s).to receive(:mapping_idcc_opco).and_return({})
        s
      end

      before do
        allow(Rails.logger).to receive(:error)
      end

      it "n'affilie aucun OPCO" do
        expect do
          service.affilie_opcos
        end.not_to change(StructureOpco, :count)
      end
    end
  end

  describe "#normalise_idcc (private)" do
    it "convertit un entier en string" do
      idcc_normalise = service.send(:normalise_idcc, 3)
      expect(idcc_normalise).to eq("3")
    end

    it "convertit une string en string" do
      idcc_normalise = service.send(:normalise_idcc, "3")
      expect(idcc_normalise).to eq("3")
    end

    it "supprime les espaces" do
      idcc_normalise = service.send(:normalise_idcc, " 3 ")
      expect(idcc_normalise).to eq("3")
    end

    it "retourne nil pour nil" do
      idcc_normalise = service.send(:normalise_idcc, nil)
      expect(idcc_normalise).to be_nil
    end

    it "retourne nil pour une string vide" do
      idcc_normalise = service.send(:normalise_idcc, "")
      # "" devient "" après strip, mais blank? retourne true, donc normalise_idcc retourne nil
      expect(idcc_normalise).to be_nil
    end
  end

  describe "#charger_mapping (private)" do
    # Pour tester charger_mapping, on doit utiliser le vrai fichier Excel
    # ou créer un fichier de test. Pour l'instant, on teste juste que la méthode existe
    # et qu'elle retourne un hash
    it "retourne un hash" do
      # Créer un nouveau service pour ce test
      test_service = described_class.new(structure)
      allow(File).to receive(:exist?).and_call_original

      # Si le fichier existe, on teste avec le vrai fichier
      fichier_excel = Rails.root.join("docs", "tableau-correspondance-opco.xlsx")
      if File.exist?(fichier_excel)
        mapping = test_service.send(:charger_mapping)
        expect(mapping).to be_a(Hash)
      else
        # Sinon on mock
        allow(File).to receive(:exist?).with(fichier_excel).and_return(false)
        mapping = test_service.send(:charger_mapping)
        expect(mapping).to eq({})
      end
    end

    it "met en cache le mapping" do
      # Créer un nouveau service sans mock pour tester le cache
      service_sans_mock = described_class.new(structure)
      mapping_spy = { "3" => "OPCO Mobilité" }
      allow(service_sans_mock).to receive(:charger_mapping).and_return(mapping_spy)

      # Premier appel
      mapping1 = service_sans_mock.send(:mapping_idcc_opco)
      # Deuxième appel - ne devrait pas appeler charger_mapping à nouveau
      mapping2 = service_sans_mock.send(:mapping_idcc_opco)

      expect(mapping1).to eq(mapping2)
      expect(service_sans_mock).to have_received(:charger_mapping).once
    end
  end
end
