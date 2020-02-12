# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Maintenance::NombreErreurs do
  let(:metrique_nombre_erreurs) do
    described_class.new(evenements_decores(evenements)).calcule
  end

  describe '#metrique nombre_erreurs' do
    context "aucun événement d'identification" do
      let(:evenements) do
        [
          build(:evenement_demarrage)
        ]
      end
      it { expect(metrique_nombre_erreurs).to eq 0 }
    end

    context 'avec une bonne réponse' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_identification_mot, :bon)
        ]
      end
      it { expect(metrique_nombre_erreurs).to eq 0 }
    end

    context 'avec une non réponse' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_identification_mot, :non_reponse)
        ]
      end
      it { expect(metrique_nombre_erreurs).to eq 0 }
    end

    context 'avec une mauvaise réponse' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_identification_mot, :mauvais)
        ]
      end
      it { expect(metrique_nombre_erreurs).to eq 1 }
    end
  end
end
