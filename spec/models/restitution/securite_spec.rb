# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Securite do
  let(:campagne) { Campagne.new }
  let(:restitution) { Restitution::Securite.new campagne, evenements }

  describe '#termine?' do
    context 'aucun danger qualifié' do
      let(:evenements) { [] }
      it { expect(restitution).to_not be_termine }
    end

    context 'tous les dangers qualifiés' do
      let(:evenements) do
        Array.new(Restitution::Securite::DANGERS_TOTAL) do |index|
          build(:evenement_qualification_danger, donnees: { danger: "danger-#{index}" })
        end
      end
      it { expect(restitution).to be_termine }
    end

    context 'ignore les requalifications de danger' do
      let(:evenements) do
        Array.new(Restitution::Securite::DANGERS_TOTAL) do
          build(:evenement_qualification_danger, donnees: { danger: 'danger' })
        end
      end
      it { expect(restitution).to_not be_termine }
    end
  end

  describe '#nombre_bien_qualifies' do
    context 'sans évenement' do
      let(:evenements) { [] }
      it { expect(restitution.nombre_bien_qualifies).to eq 0 }
    end

    context 'avec bonne qualification' do
      let(:evenements) { [build(:evenement_qualification_danger, :bon)] }
      it { expect(restitution.nombre_bien_qualifies).to eq 1 }
    end

    context 'ignore les mauvaises qualifications' do
      let(:evenements) { [build(:evenement_qualification_danger, :mauvais)] }
      it { expect(restitution.nombre_bien_qualifies).to eq 0 }
    end

    context 'prend en compte la requalification' do
      let(:evenements) do
        [build(:evenement_qualification_danger,
               donnees: { reponse: 'mauvais', danger: 'danger' }, created_at: 1.minute.ago),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'bonne', danger: 'danger' }, created_at: 2.minutes.ago)]
      end
      it { expect(restitution.nombre_bien_qualifies).to eq 0 }
    end
  end
end
