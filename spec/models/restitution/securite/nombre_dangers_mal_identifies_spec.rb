require 'rails_helper'

describe Restitution::Securite::NombreDangersMalIdentifies do
  let(:metrique_nombre_dangers_mal_identifies) do
    described_class.new.calcule(evenements_decores(evenements, :securite), [])
  end

  describe '#nombre_dangers_mal_identifies' do
    context 'sans évenement' do
      let(:evenements) { [] }

      it { expect(metrique_nombre_dangers_mal_identifies).to eq 0 }
    end

    context 'avec une bonne identification' do
      let(:evenements) do
        [ build(:evenement_demarrage),
         build(:evenement_identification_danger, donnees: { reponse: 'oui', danger: 'danger' }) ]
      end

      it { expect(metrique_nombre_dangers_mal_identifies).to eq 0 }
    end

    context 'avec une mauvaise identification' do
      let(:evenements) do
        [ build(:evenement_demarrage),
         build(:evenement_identification_danger, donnees: { reponse: 'non', danger: 'danger' }) ]
      end

      it { expect(metrique_nombre_dangers_mal_identifies).to eq 1 }
    end
  end
end
