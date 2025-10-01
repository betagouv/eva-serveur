require 'rails_helper'

describe Anonymisation::Campagne do
  describe '#anonymise' do
    let(:campagne) { create :campagne, libelle: 'toto' }

    it 'anonymise avec un nom généré' do
      allow(FFaker::Product).to receive(:product_name).and_return('tata')
      described_class.new(campagne).anonymise
      campagne.reload
      expect(campagne.libelle).to eq 'tata'
    end
  end
end
