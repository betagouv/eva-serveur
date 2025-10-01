require 'rails_helper'

describe StatistiquesCampagne do
  let(:campagne) { create :campagne }
  let(:date_debut_evaluation) { Time.zone.local(2021, 1, 1, 8, 2) }
  let(:maintenance) { create :situation_maintenance }

  describe '#calcule!' do
    context 'Sans evaluation' do
      it do
        statistiques = described_class.new(campagne)
        expect(statistiques.temps_min).to be_nil
        expect(statistiques.temps_max).to be_nil
        expect(statistiques.temps_moyen).to be_nil
      end
    end

    context 'Avec des évaluations' do
      let!(:evaluation1) do
        create :evaluation, campagne: campagne, debutee_le: date_debut_evaluation
      end
      let(:partie1) { create :partie, situation: maintenance, evaluation: evaluation1 }
      let(:evaluation2) do
        create :evaluation, campagne: campagne, debutee_le: date_debut_evaluation
      end
      let(:partie2) { create :partie, situation: maintenance, evaluation: evaluation2 }

      context 'sans événements' do
        it do
          statistiques = described_class.new(campagne)
          expect(statistiques.temps_min).to be_nil
          expect(statistiques.temps_max).to be_nil
          expect(statistiques.temps_moyen).to be_nil
        end
      end

      context 'avec une évaluation avec des événements' do
        let!(:fin1) do
          create :evenement_fin_situation, partie: partie1,
                                           date: Time.zone.local(2021, 1, 1, 8, 4)
        end

        it do
          statistiques = described_class.new(campagne)
          expect(statistiques.to_h).to eql(
            {
              temps_min: 120.0,
              temps_max: 120.0,
              temps_moyen: 120.0
            }
          )
        end
      end

      context 'avec deux évaluations avec des événements' do
        let!(:fin1) do
          create :evenement_fin_situation, partie: partie1,
                                           date: Time.zone.local(2021, 1, 1, 8, 4)
        end
        let!(:fin2) do
          create :evenement_fin_situation, partie: partie2,
                                           date: Time.zone.local(2021, 1, 1, 8, 6)
        end

        it do
          statistiques = described_class.new(campagne)
          expect(statistiques.to_h).to eql(
            {
              temps_min: 120.0,
              temps_max: 240.0,
              temps_moyen: 180.0
            }
          )
        end
      end
    end
  end
end
