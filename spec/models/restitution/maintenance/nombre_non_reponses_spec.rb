require 'rails_helper'

describe Restitution::Maintenance::NombreNonReponses do
  let(:metrique_nombre_erreurs) do
    described_class.new.calcule(evenements_decores(evenements, :maintenance), [])
  end

  describe '#metrique nombre_non_reponses' do
    context "aucun événement d'identification" do
      let(:evenements) do
        [
          build(:evenement_demarrage)
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

      it { expect(metrique_nombre_erreurs).to eq 1 }
    end

    context 'avec une réponse' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_identification_mot, :pas_français_mal_identifie)
        ]
      end

      it { expect(metrique_nombre_erreurs).to eq 0 }
    end
  end
end
