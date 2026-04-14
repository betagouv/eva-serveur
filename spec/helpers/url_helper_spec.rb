require 'rails_helper'

describe UrlHelper do
  describe '#humanize_url' do
    it 'retire https:// et www.' do
      expect(helper.humanize_url('https://www.constructys.fr')).to eq('constructys.fr')
    end

    it 'retire http:// et www.' do
      expect(helper.humanize_url('http://www.exemple.fr')).to eq('exemple.fr')
    end

    it 'retir le dernier /' do
      expect(helper.humanize_url('constructys.fr/contacts/')).to eq('constructys.fr/contacts')
    end

    it 'laisse url inchangée sans protocole ni www.' do
      expect(helper.humanize_url('constructys.fr/contacts')).to eq('constructys.fr/contacts')
    end
  end
end
