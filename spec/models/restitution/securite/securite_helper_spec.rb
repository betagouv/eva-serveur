# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Securite::SecuriteHelper do
  describe '#filtre_par_danger' do
    let(:e1) { Evenement.new donnees: { 'danger' => 'signalisation' } }
    let(:e2) { Evenement.new donnees: { 'danger' => 'camion' } }

    it 'trie les dangers par ordre alphabetique' do
      expect(described_class.filtre_par_danger([ e1, e2 ], &:present?).keys)
        .to eql(%w[camion signalisation])
    end
  end
end
