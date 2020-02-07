# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Securite::NombreDangersMalIdentifies do
  let(:campagne) { Campagne.new }
  let(:restitution) { Restitution::Securite.new campagne, evenements }

  describe '#nombre_dangers_mal_identifies' do
    context 'sans évenement' do
      let(:evenements) { [] }
      it { expect(restitution.nombre_dangers_mal_identifies).to eq 0 }
    end

    context 'avec une bonne identification' do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_identification_danger, donnees: { reponse: 'oui', danger: 'danger' })]
      end
      it { expect(restitution.nombre_dangers_mal_identifies).to eq 0 }
    end

    context 'avec une mauvaise identification' do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_identification_danger, donnees: { reponse: 'non', danger: 'danger' })]
      end
      it { expect(restitution.nombre_dangers_mal_identifies).to eq 1 }
    end
  end
end
