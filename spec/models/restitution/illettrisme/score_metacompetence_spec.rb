# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Illettrisme::ScoreMetacompetence do
  describe '#calcule' do
    let(:evenements) { double }
    let(:metacompetence) { 'ccf' }
    let(:score) do
      described_class.new.calcule(evenements, metacompetence)
    end

    context 'pas de bonnes réponses' do
      before do
        nombre_bonnes_reponse_est 0
      end

      it { expect(score).to eq(0) }
    end

    context 'temps moyen à 0' do
      before do
        nombre_bonnes_reponse_est 1
        temps_moyen_bonnes_reponses_est 0
      end

      it { expect(score).to be_nil }
    end

    context 'divise le nombre de bonnes réponses par le temps moyen' do
      before do
        nombre_bonnes_reponse_est 3
        temps_moyen_bonnes_reponses_est 2
      end

      it { expect(score).to eq(1.5) }
    end

    def nombre_bonnes_reponse_est(nombre)
      mock_nombre_bonnes_reponses = double

      allow(Restitution::Illettrisme::NombreBonnesReponses).to receive(:new)
        .and_return mock_nombre_bonnes_reponses

      allow(mock_nombre_bonnes_reponses).to receive(:calcule)
        .with(evenements, metacompetence).and_return(nombre)
    end

    def temps_moyen_bonnes_reponses_est(valeur)
      mock_moyenne = double

      allow(Restitution::Metriques::Moyenne).to receive(:new)
        .with(mock_temps_bonnes_reponses).and_return(mock_moyenne)

      allow(mock_moyenne).to receive(:calcule).with(evenements, metacompetence).and_return(valeur)
    end

    def mock_temps_bonnes_reponses
      mock_temps_bonnes_reponses = double

      allow(Restitution::Illettrisme::TempsBonnesReponses).to receive(:new)
        .and_return(mock_temps_bonnes_reponses)

      mock_temps_bonnes_reponses
    end
  end
end
