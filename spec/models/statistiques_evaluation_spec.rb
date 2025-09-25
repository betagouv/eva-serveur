# frozen_string_literal: true

require 'rails_helper'

describe StatistiquesEvaluation do
  let(:date_debut_evaluation) { Time.zone.local(2021, 1, 1, 8, 2) }
  let(:evaluation) { create :evaluation, debutee_le: date_debut_evaluation }
  let!(:partie) { create :partie, evaluation: evaluation }

  describe '#calcule_temps_total' do
    context 'avec une date de fin' do
      it do
        evaluation.terminee_le = Time.zone.local(2021, 1, 1, 8, 4)
        expect(described_class.new(evaluation).temps_total).to be(120.0)
      end
    end

    context 'avec des événements' do
      let!(:debut) do
        create :evenement_demarrage, partie: partie, date: Time.zone.local(2021, 1, 1, 8, 3)
      end
      let!(:fin) do
        create :evenement_fin_situation, partie: partie,
                                         date: Time.zone.local(2021, 1, 1, 8, 4)
      end

      it { expect(described_class.new(evaluation).temps_total).to be(120.0) }
    end

    context 'sans événements' do
      it do
        statistiques = described_class.new(evaluation)
        expect(statistiques.temps_total).to be_nil
      end
    end
  end
end
