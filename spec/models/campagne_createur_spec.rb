require "rails_helper"

describe CampagneCreateur, type: :model do
  let(:compte) { create(:compte_admin) }
  let(:opco) { create(:opco, :constructys) }
  let(:structure_entreprise) do
    structure = create(:structure_locale,
                       nom: "ma super structure",
                       type_structure: "entreprise",
                       usage: "Eva: entreprises")
    structure.opcos << opco
    structure
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

      it "crée deux campagnes : une spécifique et une générique" do
        expect do
          createur.cree_campagne_opco!
        end.to change(Campagne, :count).by(2)

        campagnes = Campagne.last(2)
        campagne_specifique = campagnes.find { |c| c.parcours_type == parcours_type }
        campagne_generique = campagnes.find { |c| c.parcours_type == parcours_type_generique }

        expect(campagne_specifique.libelle).to eq("Diagnostic des risques : ma super structure")
        expect(campagne_specifique.compte).to eq(compte)
        expect(campagne_specifique.parcours_type).to eq(parcours_type)

        expect(campagne_generique.libelle).to eq("Diagnostic standard evapro")
        expect(campagne_generique.compte).to eq(compte)
        expect(campagne_generique.parcours_type).to eq(parcours_type_generique)
      end
    end

    context "quand le parcours type spécifique n'existe pas" do
      before { parcours_type_generique }

      it do
        expect do
          createur.cree_campagne_opco!
        end.to raise_error(ActiveRecord::RecordNotFound)
        expect(Campagne.count).to eq 0
      end
    end

    context "quand le parcours type générique n'existe pas" do
      before { parcours_type }

      it "crée la première campagne puis lève une erreur" do
        expect do
          createur.cree_campagne_opco!
        end.to raise_error(ActiveRecord::RecordNotFound)
        # La première campagne est créée avant l'erreur sur la deuxième
        expect(Campagne.count).to eq 1
      end
    end

    context "quand la structure n'est pas de type entreprise" do
      let(:structure_non_entreprise) do
        structure = create(:structure_locale,
                           type_structure: "mission_locale",
                           usage: "Eva: entreprises")
        structure.opcos << opco
        structure
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
        structure = create(:structure_locale,
                           type_structure: "entreprise",
                           usage: "Eva: bénéficiaires")
        structure.opcos << opco
        structure
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
        structure = create(:structure_locale,
                           type_structure: "entreprise",
                           usage: "Eva: entreprises")
        structure.opcos << opco_sante
        structure
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

      it "trouve le bon parcours type en fonction de l'OPCO et crée deux campagnes" do
        expect do
          createur_sante.cree_campagne_opco!
        end.to change(Campagne, :count).by(2)

        campagnes = Campagne.last(2)
        campagne_specifique = campagnes.find { |c| c.parcours_type == parcours_type_sante }
        campagne_generique = campagnes.find { |c| c.parcours_type == parcours_type_generique }

        expect(campagne_specifique).to be_present
        expect(campagne_specifique.parcours_type).to eq(parcours_type_sante)
        expect(campagne_generique).to be_present
        expect(campagne_generique.parcours_type).to eq(parcours_type_generique)
      end
    end

    context "quand l'OPCO n'est pas financeur" do
      let(:opco_non_financeur) { create(:opco, :opco_non_financeur) }
      let(:structure_opco_non_financeur) do
        structure = create(:structure_locale,
                           type_structure: "entreprise",
                           usage: "Eva: entreprises")
        structure.opcos << opco_non_financeur
        structure
      end
      let(:parcours_type_generique) do
        create(:parcours_type,
               nom_technique: "eva-entreprise",
               libelle: "Eva entreprises",
               type_de_programme: :diagnostic)
      end
      let(:createur_non_financeur) { described_class.new(structure_opco_non_financeur, compte) }

      before { parcours_type_generique }

      it "crée deux campagnes avec le parcours type générique" do
        expect do
          createur_non_financeur.cree_campagne_opco!
        end.to change(Campagne, :count).by(2)

        campagnes = Campagne.last(2)
        campagne_specifique = campagnes.find { |c| c.libelle.include?("Diagnostic des risques") }
        campagne_generique = campagnes.find { |c| c.libelle == "Diagnostic standard evapro" }

        expect(campagne_specifique.libelle).to eq(
          "Diagnostic des risques : #{structure_opco_non_financeur.nom}"
        )
        expect(campagne_specifique.parcours_type).to eq(parcours_type_generique)
        expect(campagne_generique.libelle).to eq("Diagnostic standard evapro")
        expect(campagne_generique.parcours_type).to eq(parcours_type_generique)
      end
    end
  end

  describe "#genere_nom_technique_parcours (private)" do
    it "génère le bon nom technique pour Constructys" do
      nom_technique = createur.send(:genere_nom_technique_parcours)
      expect(nom_technique).to eq("eva-entreprise-constructys")
    end

    context "avec OPCO Santé" do
      let(:opco) { create(:opco, :opco_sante) }
      let(:structure_entreprise) do
        structure = create(:structure_locale,
                           nom: "ma super structure",
                           type_structure: "entreprise",
                           usage: "Eva: entreprises")
        structure.opcos << opco
        structure
      end

      it "génère le bon nom technique en supprimant les espaces et accents" do
        nom_technique = createur.send(:genere_nom_technique_parcours)
        expect(nom_technique).to eq("eva-entreprise-opcosante")
      end
    end

    context "avec un nom d'OPCO contenant des caractères spéciaux" do
      let(:opco) { create(:opco, :opco_mobilites) }
      let(:structure_entreprise) do
        structure = create(:structure_locale,
                           nom: "ma super structure",
                           type_structure: "entreprise",
                           usage: "Eva: entreprises")
        structure.opcos << opco
        structure
      end

      it "génère le bon nom technique en normalisant les caractères" do
        nom_technique = createur.send(:genere_nom_technique_parcours)
        expect(nom_technique).to eq("eva-entreprise-opcomobilites")
      end
    end

    context "quand l'OPCO n'est pas financeur" do
      let(:opco) { create(:opco, :opco_non_financeur) }
      let(:structure_entreprise) do
        structure = create(:structure_locale,
                           nom: "ma super structure",
                           type_structure: "entreprise",
                           usage: "Eva: entreprises")
        structure.opcos << opco
        structure
      end

      it "génère le nom technique générique" do
        nom_technique = createur.send(:genere_nom_technique_parcours)
        expect(nom_technique).to eq("eva-entreprise")
      end
    end

    context "quand la structure a plusieurs OPCOs" do
      let(:opco_financeur) { create(:opco, nom: "OPCO Financeur", financeur: true) }
      let(:opco_non_financeur) { create(:opco, :opco_non_financeur) }
      let(:structure_multi_opco) do
        structure = create(:structure_locale,
                           nom: "structure multi-opco",
                           type_structure: "entreprise",
                           usage: "Eva: entreprises")
        structure.opcos << [ opco_non_financeur, opco_financeur ]
        structure
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
      let(:createur_multi) { described_class.new(structure_multi_opco, compte) }

      before do
        parcours_type_financeur
        parcours_type_generique
      end

      it "utilise le premier OPCO financeur" do
        premier_opco = createur_multi.send(:premier_opco_financeur)
        expect(premier_opco).to eq(opco_financeur)
      end

      it "crée deux campagnes : une avec le parcours type du financeur et une générique" do
        expect do
          createur_multi.cree_campagne_opco!
        end.to change(Campagne, :count).by(2)

        campagnes = Campagne.last(2)
        campagne_specifique = campagnes.find { |c| c.parcours_type == parcours_type_financeur }
        campagne_generique = campagnes.find { |c| c.parcours_type == parcours_type_generique }

        expect(campagne_specifique.parcours_type).to eq(parcours_type_financeur)
        expect(campagne_generique.parcours_type).to eq(parcours_type_generique)
      end
    end

    context "quand la structure a plusieurs OPCOs mais aucun financeur" do
      let(:opco1) { create(:opco, nom: "OPCO 1", financeur: false) }
      let(:opco2) { create(:opco, nom: "OPCO 2", financeur: false) }
      let(:structure_multi_non_financeur) do
        structure = create(:structure_locale,
                           nom: "structure multi-opco",
                           type_structure: "entreprise",
                           usage: "Eva: entreprises")
        structure.opcos << [ opco1, opco2 ]
        structure
      end
      let(:parcours_type_generique) do
        create(:parcours_type,
               nom_technique: "eva-entreprise",
               libelle: "Eva entreprises",
               type_de_programme: :diagnostic)
      end
      let(:createur_multi) { described_class.new(structure_multi_non_financeur, compte) }

      before { parcours_type_generique }

      it "utilise le premier OPCO" do
        premier_opco = createur_multi.send(:premier_opco_financeur)
        expect(premier_opco).to eq(opco1)
      end

      it "crée deux campagnes avec le parcours type générique" do
        expect do
          createur_multi.cree_campagne_opco!
        end.to change(Campagne, :count).by(2)

        campagnes = Campagne.last(2)
        campagne_specifique = campagnes.find { |c| c.libelle.include?("Diagnostic des risques") }
        campagne_generique = campagnes.find { |c| c.libelle == "Diagnostic standard evapro" }

        expect(campagne_specifique.parcours_type).to eq(parcours_type_generique)
        expect(campagne_generique.parcours_type).to eq(parcours_type_generique)
      end
    end
  end
end
