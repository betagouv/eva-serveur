# frozen_string_literal: true

require 'rails_helper'

describe CampagneHelper do
  describe '#url_campagne' do
    it 'echape le code campagne' do
      stub_const('::URL_CLIENT', 'https://URL_CLIENT')
      expect(url_campagne('CODE')).to eq('https://URL_CLIENT?code=CODE')
      expect(url_campagne('CODE 2')).to eq('https://URL_CLIENT?code=CODE%202')
    end
  end
end
