# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Maintenance::ScoreVocabulaire do
  let(:mock_metrique_nombre_mot_francais) { double }
  let(:mock_metrique_nombre_non_mot) { double }
  let(:metrique_score_ccf) do
    described_class
      .new(mock_metrique_nombre_mot_francais, mock_metrique_nombre_non_mot)
  end

  describe '#score' do
    def pour_nombre(nombre_francais, nombre_non_mots)
      allow(mock_metrique_nombre_mot_francais).to receive(:calcule).and_return(nombre_francais)
      allow(mock_metrique_nombre_non_mot).to receive(:calcule).and_return(nombre_non_mots)
    end

    def score_pour(nombre_francais, temps_francais, nombre_non_mots, temps_non_mots)
      pour_nombre(nombre_francais, nombre_non_mots)
      allow(metrique_score_ccf).to receive(:temps_moyen_normalise)
        .and_return(temps_francais, temps_non_mots)

      metrique_score_ccf.calcule([], [])
    end

    it { expect(score_pour(0, nil, 0, nil)).to eq(0) }
    it { expect(score_pour(2, 1.5, 0, nil)).to eq(0) }
    it { expect(score_pour(2, nil, 5, 3)).to eq(0) }
    it { expect(score_pour(2, 1.5, 5, 3)).to eq((2 / 1.5) * (5 / 3)) }
  end

  describe '#temps_moyen_normalise' do
    context 'calcule le temps moyen normalises pour les mots francais' do
      let!(:standardisateur) { double }
      let(:mock_metrique_temps) { double }

      it do
        allow(standardisateur).to receive_messages(
          moyennes_metriques: { temps_moyen_mots_francais: 2.7 }, ecarts_types_metriques: { temps_moyen_mots_francais: 0.5 }
        )

        allow(metrique_score_ccf).to receive(:standardisateur).and_return(standardisateur)

        expect(mock_metrique_temps).to receive(:calcule).and_return([2.7, 3.7, 3.8])
        temps_moyen_normalise = metrique_score_ccf
                                .temps_moyen_normalise(:temps_moyen_mots_francais,
                                                       mock_metrique_temps)
        expect(temps_moyen_normalise).to eq((2.7 + 3.7) / 2.0)
      end
    end
  end
end
