require 'rails_helper'

describe Restitution::Maintenance::NombreBonnesReponsesNonMot do
  let(:metrique_nombre_bonnes_reponses_non_mot) do
    described_class.new.calcule(evenements_decores(evenements, :maintenance), [])
  end

  describe '#metrique metrique_nombre_bonnes_reponses_non_mot' do
    context "aucun événement d'identification" do
      let(:evenements) do
        [
          build(:evenement_demarrage)
        ]
      end

      it { expect(metrique_nombre_bonnes_reponses_non_mot).to eq 0 }
    end

    context 'avec une bonne réponse non-mot' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_identification_mot, :pas_français_bien_identifie)
        ]
      end

      it { expect(metrique_nombre_bonnes_reponses_non_mot).to eq 1 }
    end

    context 'avec une mauvaise réponse non-mot' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_identification_mot, :pas_français_mal_identifie)
        ]
      end

      it { expect(metrique_nombre_bonnes_reponses_non_mot).to eq 0 }
    end

    context 'avec une bonne réponse mot français' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_identification_mot, donnees: { type: 'neutre', reponse: 'francais' })
        ]
      end

      it { expect(metrique_nombre_bonnes_reponses_non_mot).to eq 0 }
    end
  end
end
