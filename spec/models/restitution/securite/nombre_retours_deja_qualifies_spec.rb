# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Securite::NombreRetoursDejaQualifies do
  let(:metrique_nombre_retours_deja_qualifies) do
    described_class.new.calcule(evenements_decores(evenements, :securite), [])
  end

  describe '#nombre_retours_deja_qualifies' do
    context 'sans évenement' do
      let(:evenements) { [] }

      it { expect(metrique_nombre_retours_deja_qualifies).to eq 0 }
    end

    context 'deux qualifications de dangers différents' do
      let(:evenements) do
        [ build(:evenement_demarrage),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'mauvais', danger: 'danger1' }),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'bonne', danger: 'danger2' }) ]
      end

      it { expect(metrique_nombre_retours_deja_qualifies).to eq 0 }
    end

    context 'deux qualifications du même danger' do
      let(:evenements) do
        [ build(:evenement_demarrage),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'mauvais', danger: 'danger' }),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'bonne', danger: 'danger' }) ]
      end

      it { expect(metrique_nombre_retours_deja_qualifies).to eq 1 }
    end
  end
end
