# frozen_string_literal: true

require 'rails_helper'

describe StatistiquesEvaluation do
  let(:date_creation_evaluation) { Time.local(2021, 1, 1, 8, 2) }
  let(:evaluation) { create :evaluation, nom: 'Test', created_at: date_creation_evaluation }
  let!(:partie) { create :partie, evaluation: evaluation }

  describe '#calcule!' do
    context 'avec des événements' do
      let!(:debut) do
        create :evenement_demarrage, partie: partie, created_at: Time.local(2021, 1, 1, 8, 3)
      end
      let!(:fin) do
        create :evenement_fin_situation, partie: partie, created_at: Time.local(2021, 1, 1, 8, 4)
      end

      it { expect(described_class.new(evaluation).temps_total).to eql(120.0) }
    end

    context 'sans événements' do
      it do
        statistiques = described_class.new(evaluation)
        expect(statistiques.temps_total).to eql(nil)
        expect(statistiques.fin).to eql(nil)
        expect(statistiques.debut).to eql(date_creation_evaluation)
      end
    end
  end
end
