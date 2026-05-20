require 'rails_helper'

describe StatistiquesStructure do
  describe '#correlation_entre_niveau_illettrisme_et_genre' do
    let(:structure) { create :structure }
    let(:compte) { create :compte, structure: structure }
    let(:campagne) { create :campagne, compte: compte }

    let(:evaluation) do
      create :evaluation, campagne: campagne, synthese_competences_de_base: :illettrisme_potentiel
    end
    let(:evaluation2) do
      create :evaluation, campagne: campagne, synthese_competences_de_base: :illettrisme_potentiel
    end
    let(:evaluation_autre) do
      create :evaluation, synthese_competences_de_base: :illettrisme_potentiel
    end

    let(:resultat) do
      described_class.new(structure)
                     .correlation_entre_niveau_illettrisme_et_genre(:illettrisme_potentiel)
    end

    context "quand la structure n'a pas de données sociodémographiques" do
      it 'ne renvoie rien' do
        expect(resultat).to be_nil
      end
    end

    context 'quand la structure a des données sociodémographiques' do
      let!(:donnee_sociodemographique) do
        create :donnee_sociodemographique, genre: 'femme', evaluation: evaluation
      end
      let!(:donnee_sociodemographique2) do
        create :donnee_sociodemographique, genre: 'homme', evaluation: evaluation2
      end
      let!(:donnee_sociodemographique_autre) do
        create :donnee_sociodemographique, genre: 'homme', evaluation: evaluation_autre
      end

      it "renvoie le pourcentage d'un genre donné" do
        expect(resultat['femme']).to be(50.0)
        expect(resultat['homme']).to be(50.0)
      end

      it 'assigne zero aux genres sans évaluation' do
        expect(resultat['autre']).to be(0)
      end
    end
  end
end
