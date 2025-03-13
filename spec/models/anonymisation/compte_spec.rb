# frozen_string_literal: true

require 'rails_helper'

describe Anonymisation::Compte do
  describe '#anonymise' do
    let(:compte) do
      create :compte, prenom: 'toto', nom: 'dupont', telephone: '06…', email: 'toto@dupont.fr'
    end

    it 'anonymise avec un nom généré' do
      allow(FFaker::NameFR).to receive_messages(first_name: 'tata', last_name: 'dupuis')
      described_class.new(compte).anonymise
      compte.reload
      expect(compte.prenom).to eq 'tata'
      expect(compte.nom).to eq 'dupuis'
      expect(compte.telephone).to be_nil
      expect(compte.email).to match(/tata\.dupuis\.\d{1,3}@eva\.fr/)
    end
  end
end
