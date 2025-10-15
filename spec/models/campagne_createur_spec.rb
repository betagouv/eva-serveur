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

  let(:createur) { described_class.new(structure_entreprise, compte) }

  describe "#cree_campagne_opco!" do
    context "quand toutes les conditions sont réunies" do
      before { parcours_type } # Créer le parcours type

      it "crée une campagne avec le nom par défaut" do
        expect do
          createur.cree_campagne_opco!
        end.to change(Campagne, :count).by(1)

        campagne = Campagne.last
        expect(campagne.libelle).to eq("Diagnostic des risques : ma super structure")
        expect(campagne.compte).to eq(compte)
        expect(campagne.parcours_type).to eq(parcours_type)
      end

      it "associe le type de programme du parcours type" do
        campagne = createur.cree_campagne_opco!

        expect(campagne.type_programme).to eq("diagnostic")
      end
    end

    context "quand le parcours type n'existe pas" do
      it do
        expect do
          createur.cree_campagne_opco!
        end.to raise_error(ActiveRecord::RecordNotFound)
        expect(Campagne.count).to eq 0
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
               usage: "Eva: entreprises",
               opco: nil)
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
      let(:createur_sante) { described_class.new(structure_opco_sante, compte) }

      before { parcours_type_sante }

      it "trouve le bon parcours type en fonction de l'OPCO" do
        campagne = createur_sante.cree_campagne_opco!

        expect(campagne).to be_present
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

      it "crée une campagne avec le parcours type générique" do
        expect do
          createur_non_financeur.cree_campagne_opco!
        end.to change(Campagne, :count).by(1)

        campagne = Campagne.last
        expect(campagne.libelle).to eq(
          "Diagnostic des risques : #{structure_opco_non_financeur.nom}"
        )
        expect(campagne.parcours_type).to eq(parcours_type_generique)
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

      it "génère le bon nom technique en supprimant les espaces et accents" do
        nom_technique = createur.send(:genere_nom_technique_parcours)
        expect(nom_technique).to eq("eva-entreprise-opcosante")
      end
    end

    context "avec un nom d'OPCO contenant des caractères spéciaux" do
      let(:opco) { create(:opco, :opco_mobilites) }

      it "génère le bon nom technique en normalisant les caractères" do
        nom_technique = createur.send(:genere_nom_technique_parcours)
        expect(nom_technique).to eq("eva-entreprise-opcomobilites")
      end
    end

    context "quand l'OPCO n'est pas financeur" do
      let(:opco) { create(:opco, :opco_non_financeur) }

      it "génère le nom technique générique" do
        nom_technique = createur.send(:genere_nom_technique_parcours)
        expect(nom_technique).to eq("eva-entreprise")
      end
    end
  end
end
