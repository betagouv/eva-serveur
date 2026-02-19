require "rails_helper"

describe CampagneCreateur, type: :model do
  let(:compte) { create(:compte_admin) }
  let(:opco) { create(:opco, :constructys) }
  let(:structure_entreprise) do
    create(:structure_locale,
           nom: "ma super structure",
           type_structure: "entreprise",
           usage: "Eva: entreprises",
           opco: opco)
  end
  let(:parcours_type) do
    create(:parcours_type,
           nom_technique: "eva-entreprise-constructys",
           libelle: "Eva entreprises Constructys",
           type_de_programme: :diagnostic)
  end
  let(:parcours_type_generique) do
    create(:parcours_type,
           nom_technique: "eva-entreprise",
           libelle: "Eva entreprises",
           type_de_programme: :diagnostic)
  end

  let(:createur) { described_class.new(structure_entreprise, compte) }

  describe "#cree_campagne_opco!" do
    context "quand toutes les conditions sont réunies" do
      before do
        parcours_type
        parcours_type_generique
      end

      it "crée uniquement la campagne spécifique (pas de générique)" do
        expect do
          createur.cree_campagne_opco!
        end.to change(Campagne, :count).by(1)

        campagne = Campagne.last
        expect(campagne.libelle).to eq(
          "Diagnostic des risques : ma super structure - #{parcours_type.libelle}"
        )
        expect(campagne.compte).to eq(compte)
        expect(campagne.parcours_type).to eq(parcours_type)
      end
    end

    context "quand aucun parcours type spécifique n'existe" do
      before { parcours_type_generique }

      it "ne crée aucune campagne" do
        expect do
          createur.cree_campagne_opco!
        end.not_to change(Campagne, :count)
      end
    end

    context "quand la structure n'est pas de type entreprise" do
      let(:structure_non_entreprise) do
        create(:structure_locale,
               type_structure: "mission_locale",
               usage: "Eva: entreprises",
               opco: opco)
      end
      let(:createur_non_entreprise) { described_class.new(structure_non_entreprise, compte) }

      it "ne crée pas de campagne" do
        expect do
          createur_non_entreprise.cree_campagne_opco!
        end.not_to change(Campagne, :count)
      end
    end

    context "quand l'usage n'est pas Eva: entreprises" do
      let(:structure_mauvais_usage) do
        create(:structure_locale,
               type_structure: "entreprise",
               usage: "Eva: bénéficiaires",
               opco: opco)
      end
      let(:createur_mauvais_usage) { described_class.new(structure_mauvais_usage, compte) }

      it "ne crée pas de campagne" do
        expect do
          createur_mauvais_usage.cree_campagne_opco!
        end.not_to change(Campagne, :count)
      end
    end

    context "quand la structure n'a pas d'OPCO" do
      let(:structure_sans_opco) do
        create(:structure_locale,
               type_structure: "entreprise",
               usage: "Eva: entreprises")
      end
      let(:createur_sans_opco) { described_class.new(structure_sans_opco, compte) }

      it "ne crée pas de campagne" do
        expect do
          createur_sans_opco.cree_campagne_opco!
        end.not_to change(Campagne, :count)
      end
    end

    context "avec différents OPCOs" do
      let(:opco_sante) { create(:opco, :opco_sante) }
      let(:structure_opco_sante) do
        create(:structure_locale,
               type_structure: "entreprise",
               usage: "Eva: entreprises",
               opco: opco_sante)
      end
      let(:parcours_type_sante) do
        create(:parcours_type,
               nom_technique: "eva-entreprise-opcosante",
               libelle: "Eva entreprises OPCO Santé",
               type_de_programme: :diagnostic)
      end
      let(:parcours_type_generique) do
        create(:parcours_type,
               nom_technique: "eva-entreprise",
               libelle: "Eva entreprises",
               type_de_programme: :diagnostic)
      end
      let(:createur_sante) { described_class.new(structure_opco_sante, compte) }

      before do
        parcours_type_sante
        parcours_type_generique
      end

      it "trouve le bon parcours type et crée uniquement la campagne spécifique" do
        expect do
          createur_sante.cree_campagne_opco!
        end.to change(Campagne, :count).by(1)

        campagne = Campagne.last
        expect(campagne.parcours_type).to eq(parcours_type_sante)
      end
    end

    context "quand l'OPCO n'est pas financeur" do
      let(:opco_non_financeur) { create(:opco, :opco_non_financeur) }
      let(:structure_opco_non_financeur) do
        create(:structure_locale,
               type_structure: "entreprise",
               usage: "Eva: entreprises",
               opco: opco_non_financeur)
      end
      let(:parcours_type_generique) do
        create(:parcours_type,
               nom_technique: "eva-entreprise",
               libelle: "Eva entreprises",
               type_de_programme: :diagnostic)
      end
      let(:createur_non_financeur) { described_class.new(structure_opco_non_financeur, compte) }

      before { parcours_type_generique }

      it "crée uniquement la campagne générique" do
        expect do
          createur_non_financeur.cree_campagne_opco!
        end.to change(Campagne, :count).by(1)

        campagne = Campagne.last
        expect(campagne.libelle).to eq("Diagnostic standard evapro")
        expect(campagne.parcours_type).to eq(parcours_type_generique)
      end
    end

    context "quand il existe plusieurs parcours types pour le même OPCO" do
      let(:parcours_type_constructys_nmc) do
        create(:parcours_type,
               nom_technique: "eva-entreprise-constructys-nmc",
               libelle: "Eva entreprises Constructys NMC",
               type_de_programme: :diagnostic)
      end

      before do
        parcours_type
        parcours_type_constructys_nmc
      end

      it "crée une campagne pour chaque parcours type trouvé" do
        expect do
          createur.cree_campagne_opco!
        end.to change(Campagne, :count).by(2)

        campagnes = Campagne.last(2)
        parcours_types_crees = campagnes.map(&:parcours_type)

        expect(parcours_types_crees).to contain_exactly(parcours_type,
parcours_type_constructys_nmc)
        campagne_constructys = campagnes.find { |c| c.parcours_type == parcours_type }
        campagne_constructys_nmc = campagnes.find { |c|
 c.parcours_type == parcours_type_constructys_nmc }

        expect(campagne_constructys.libelle).to eq(
          "Diagnostic des risques : ma super structure - #{parcours_type.libelle}"
        )
        expect(campagne_constructys_nmc.libelle).to eq(
          "Diagnostic des risques : ma super structure - #{parcours_type_constructys_nmc.libelle}"
        )
        campagnes.each do |campagne|
          expect(campagne.compte).to eq(compte)
        end
      end
    end

    context "quand la structure a un OPCO financeur" do
      let(:opco_financeur) { create(:opco, nom: "OPCO Financeur", financeur: true) }
      let(:structure_opco_financeur) do
        create(:structure_locale,
               nom: "structure opco financeur",
               type_structure: "entreprise",
               usage: "Eva: entreprises",
               opco: opco_financeur)
      end
      let(:parcours_type_financeur) do
        create(:parcours_type,
               nom_technique: "eva-entreprise-opcofinanceur",
               libelle: "Eva entreprises OPCO Financeur",
               type_de_programme: :diagnostic)
      end
      let(:parcours_type_generique) do
        create(:parcours_type,
               nom_technique: "eva-entreprise",
               libelle: "Eva entreprises",
               type_de_programme: :diagnostic)
      end
      let(:createur_financeur) { described_class.new(structure_opco_financeur, compte) }

      before do
        parcours_type_financeur
        parcours_type_generique
      end

      it "utilise l'OPCO financeur" do
        premier_opco = createur_financeur.send(:premier_opco_financeur)
        expect(premier_opco).to eq(opco_financeur)
      end

      it "crée uniquement la campagne avec le parcours type du financeur (pas de générique)" do
        expect do
          createur_financeur.cree_campagne_opco!
        end.to change(Campagne, :count).by(1)

        campagne = Campagne.last
        expect(campagne.parcours_type).to eq(parcours_type_financeur)
      end
    end

    context "quand la structure a un OPCO non financeur" do
      let(:opco1) { create(:opco, nom: "OPCO 1", financeur: false) }
      let(:structure_non_financeur) do
        create(:structure_locale,
               nom: "structure opco non financeur",
               type_structure: "entreprise",
               usage: "Eva: entreprises",
               opco: opco1)
      end
      let(:parcours_type_generique) do
        create(:parcours_type,
               nom_technique: "eva-entreprise",
               libelle: "Eva entreprises",
               type_de_programme: :diagnostic)
      end
      let(:createur_non_financeur) { described_class.new(structure_non_financeur, compte) }

      before { parcours_type_generique }

      it "retourne nil pour opco_financeur car l'OPCO n'est pas financeur" do
        premier_opco = createur_non_financeur.send(:premier_opco_financeur)
        expect(premier_opco).to be_nil
      end

      it "crée uniquement la campagne générique" do
        expect do
          createur_non_financeur.cree_campagne_opco!
        end.to change(Campagne, :count).by(1)

        campagne = Campagne.last
        expect(campagne.libelle).to eq("Diagnostic standard evapro")
        expect(campagne.parcours_type).to eq(parcours_type_generique)
      end
    end
  end
end
