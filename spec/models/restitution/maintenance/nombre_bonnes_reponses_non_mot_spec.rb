# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Maintenance::NombreBonnesReponsesNonMot do
  let(:metrique_nombre_bonnes_reponses_non_mot) do
    described_class.new(evenements_decores(evenements)).calcule
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
          build(:evenement_identification_mot, :bon)
        ]
      end
      it { expect(metrique_nombre_bonnes_reponses_non_mot).to eq 1 }
    end

    context 'avec une mauvaise réponse non-mot' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_identification_mot, :mauvais)
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
