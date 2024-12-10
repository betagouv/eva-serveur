# frozen_string_literal: true

require 'rails_helper'

describe Evenement, type: :model do
  it { is_expected.to validate_presence_of :nom }
  it { is_expected.to validate_uniqueness_of(:position).scoped_to(:session_id) }
  it { is_expected.to validate_presence_of :date }
  it { is_expected.to validate_presence_of :session_id }
  it { is_expected.to allow_value(nil).for :donnees }

  it do
    expect(subject).to belong_to(:partie)
      .with_primary_key(:session_id)
      .with_foreign_key(:session_id)
  end

  describe '#fin_situation?' do
    it "retourne true quand le nom de l'évènement est 'finSituation'" do
      evenement = described_class.new nom: 'finSituation'
      expect(evenement.fin_situation?).to be true
    end

    it "retourne false quand le nom de l'évènement n'est pas 'finSituation'" do
      evenement = described_class.new nom: 'autre'
      expect(evenement.fin_situation?).to be false
    end
  end
end
