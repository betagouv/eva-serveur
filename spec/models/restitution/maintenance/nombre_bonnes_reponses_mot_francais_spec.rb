require 'rails_helper'

describe Restitution::Maintenance::NombreBonnesReponsesMotFrancais do
  let(:metrique_nombre_bonnes_reponses_mf) do
    described_class.new.calcule(evenements_decores(evenements, :maintenance), [])
  end

  describe '#metrique nombre_bonnes_reponses_mot_français' do
    context "aucun événement d'identification" do
      let(:evenements) do
        [
          build(:evenement_demarrage)
        ]
      end

      it { expect(metrique_nombre_bonnes_reponses_mf).to eq 0 }
    end

    context 'avec une bonne réponse mot français' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_identification_mot, donnees: { type: 'neutre', reponse: 'francais' })
        ]
      end

      it { expect(metrique_nombre_bonnes_reponses_mf).to eq 1 }
    end

    context 'avec une mauvaise réponse mot français' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_identification_mot, donnees: { type: 'neutre', reponse: 'pasfrancais' })
        ]
      end

      it { expect(metrique_nombre_bonnes_reponses_mf).to eq 0 }
    end

    context 'avec des bonnes réponses mot français de différent types' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_identification_mot, donnees: { type: 'neutre', reponse: 'francais' }),
          build(:evenement_identification_mot,
                donnees: { type: 'emotion-peur', reponse: 'francais' }),
          build(:evenement_identification_mot,
                donnees: { type: 'emotion-positive', reponse: 'francais' })
        ]
      end

      it { expect(metrique_nombre_bonnes_reponses_mf).to eq 3 }
    end

    context 'avec une bonne réponse mais un mots non français' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_identification_mot, donnees: { type: 'non-mot', reponse: 'pasfrancais' })
        ]
      end

      it { expect(metrique_nombre_bonnes_reponses_mf).to eq 0 }
    end
  end
end
