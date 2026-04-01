require "rails_helper"

describe CampagneCreateur, type: :model do
  let(:compte) { create(:compte_admin) }
  let(:opco) { create(:opco, nom: "Constructys", financeur: true) }
  let(:structure_entreprise) do
    create(:structure_locale,
           nom: "ma super structure",
           type_structure: "entreprise",
           usage: "Eva: entreprises",
           opco: opco)
  end
  let(:createur) { described_class.new(structure_entreprise, compte) }

  describe "#cree_campagne_opco!" do
    context "quand la campagne peut être créée" do
      context "avec un OPCO financeur et un seul parcours type associé" do
        let(:parcours_type_associe) do
          create(:parcours_type,
                 libelle: "Eva entreprises Constructys",
                 type_de_programme: :diagnostic)
        end

        before do
          opco.opco_parcours_types.destroy_all
          create(:opco_parcours_type, opco: opco, parcours_type: parcours_type_associe)
          create(:parcours_type, nom_technique: "eva-entreprise", libelle: "Eva entreprises")
        end

        it "crée uniquement la campagne spécifique" do
          expect { createur.cree_campagne_opco! }.to change(Campagne, :count).by(1)

          campagne = Campagne.last
          expect(campagne.parcours_type).to eq(parcours_type_associe)
          expect(campagne.compte).to eq(compte)
          expect(campagne.libelle).to eq(
            "Diagnostic des risques : ma super structure - #{parcours_type_associe.libelle}"
          )
        end
      end

      context "avec un OPCO financeur et plusieurs parcours types associés" do
        let(:parcours_type_1) {
 create(:parcours_type, libelle: "Parcours A", type_de_programme: :diagnostic) }
        let(:parcours_type_2) {
 create(:parcours_type, libelle: "Parcours B", type_de_programme: :diagnostic) }

        before do
          opco.opco_parcours_types.destroy_all
          create(:opco_parcours_type, opco: opco, parcours_type: parcours_type_1)
          create(:opco_parcours_type, opco: opco, parcours_type: parcours_type_2)
        end

        it "crée une campagne par parcours type associé" do
          expect { createur.cree_campagne_opco! }.to change(Campagne, :count).by(2)

          campagnes = Campagne.last(2)
          expect(campagnes.map(&:parcours_type)).to contain_exactly(parcours_type_1,
parcours_type_2)
          expect(campagnes.map(&:compte).uniq).to eq([ compte ])
          expect(campagnes.map(&:libelle)).to contain_exactly(
            "Diagnostic des risques : ma super structure - #{parcours_type_1.libelle}",
            "Diagnostic des risques : ma super structure - #{parcours_type_2.libelle}"
          )
        end
      end

      context "avec un OPCO non financeur" do
        let(:opco) { create(:opco, nom: "OPCO non financeur", financeur: false) }
        let!(:parcours_type_generique) do
          create(:parcours_type,
                 nom_technique: "eva-entreprise",
                 libelle: "Eva entreprises",
                 type_de_programme: :diagnostic)
        end

        it "crée uniquement la campagne générique" do
          expect { createur.cree_campagne_opco! }.to change(Campagne, :count).by(1)

          campagne = Campagne.last
          expect(campagne.parcours_type).to eq(parcours_type_generique)
          expect(campagne.compte).to eq(compte)
          expect(campagne.libelle).to eq("Diagnostic standard evapro")
        end
      end
    end

    context "quand la campagne ne doit pas être créée" do
      context "avec un OPCO financeur sans parcours type associé" do
        it "ne crée aucune campagne" do
          opco.opco_parcours_types.destroy_all
          expect { createur.cree_campagne_opco! }.not_to change(Campagne, :count)
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

        it "ne crée aucune campagne" do
          expect { createur_sans_opco.cree_campagne_opco! }.not_to change(Campagne, :count)
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

        it "ne crée aucune campagne" do
          expect { createur_mauvais_usage.cree_campagne_opco! }.not_to change(Campagne, :count)
        end
      end

      context "quand la structure n'est pas de type StructureLocale" do
        let(:structure_administrative) do
          create(:structure_administrative,
                 type_structure: "entreprise",
                 usage: "Eva: entreprises",
                 opco: opco)
        end
        let(:createur_structure_administrative) {
 described_class.new(structure_administrative, compte) }

        it "ne crée aucune campagne" do
          expect {
 createur_structure_administrative.cree_campagne_opco! }.not_to change(Campagne, :count)
        end
      end

      context "quand le type de structure n'est pas entreprise" do
        let(:structure_non_entreprise) do
        create(:structure_locale,
                 type_structure: "mission_locale",
                 usage: "Eva: entreprises",
                 opco: opco)
        end
        let(:createur_non_entreprise) { described_class.new(structure_non_entreprise, compte) }

        it "ne crée aucune campagne" do
          opco.opco_parcours_types.destroy_all
          expect { createur_non_entreprise.cree_campagne_opco! }.not_to change(Campagne, :count)
        end
      end

      context "quand le type et l'usage ne sont pas éligibles" do
        let(:structure_ineligible) do
          create(:structure_locale,
               type_structure: "mission_locale",
               usage: "Eva: entreprises",
                 opco: opco)
        end
        let(:createur_ineligible) { described_class.new(structure_ineligible, compte) }

        it "ne crée aucune campagne" do
          opco.opco_parcours_types.destroy_all
          expect { createur_ineligible.cree_campagne_opco! }.not_to change(Campagne, :count)
        end
      end
    end
  end
end
