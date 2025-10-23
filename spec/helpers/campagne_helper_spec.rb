require 'rails_helper'

describe CampagneHelper do
  describe '#url_campagne' do
    it 'echape le code campagne' do
      campagne = Campagne.new code: 'CODE 2'
      stub_const('::URL_CLIENT', 'https://URL_CLIENT')
      allow(campagne).to receive(:parcours_type).and_return(nil)
      expect(url_campagne(campagne)).to eq('https://URL_CLIENT?code=CODE%202')
    end
  end
end
