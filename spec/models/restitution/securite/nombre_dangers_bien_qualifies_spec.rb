# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Securite::NombreDangersBienQualifies do
  let(:metrique_nombre_bien_qualifies) do
    described_class.new.calcule(evenements_decores(evenements, :securite), [])
  end

  describe '#nombre_bien_qualifies' do
    context 'sans évenement' do
      let(:evenements) { [] }

      it { expect(metrique_nombre_bien_qualifies).to eq 0 }
    end

    context 'avec bonne qualification' do
      let(:evenements) do
        [ build(:evenement_demarrage),
         build(:evenement_qualification_danger, :bon) ]
      end

      it { expect(metrique_nombre_bien_qualifies).to eq 1 }
    end

    context 'ignore les mauvaises qualifications' do
      let(:evenements) do
        [ build(:evenement_demarrage),
         build(:evenement_qualification_danger, :mauvais) ]
      end

      it { expect(metrique_nombre_bien_qualifies).to eq 0 }
    end

    context 'prend en compte la requalification' do
      let(:evenements) do
        [ build(:evenement_demarrage),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'mauvais', danger: 'danger' }, created_at: 1.minute.ago),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'bonne', danger: 'danger' }, created_at: 2.minutes.ago) ]
      end

      it { expect(metrique_nombre_bien_qualifies).to eq 0 }
    end
  end
end
