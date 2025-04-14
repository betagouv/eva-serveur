# frozen_string_literal: true

require 'rails_helper'

describe Restitution::AvecEntrainement do
  let(:campagne) { Campagne.new }
  let(:restitution) { described_class.new campagne, evenements }

  describe '#evenements_situation et #evenements_entrainement' do
    context "ignore les évenements d'entrainement même s'ils ont la même date" do
      let(:demarrage_entrainement) do
        build(:evenement_demarrage_entrainement,
              date: Time.zone.local(2019, 10, 9, 10, 0))
      end
      let(:demarrage) { build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 0)) }
      let(:evenements) { [ demarrage_entrainement, demarrage ] }

      it { expect(restitution.evenements_entrainement).to eq [ demarrage_entrainement ] }
      it { expect(restitution.evenements_situation).to eq [ demarrage ] }
    end
  end
end
