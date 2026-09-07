require 'rails_helper'

describe Pdf::GenerationToken do
  describe '.genere / .compte_id' do
    it 'retrouve le compte_id à partir du jeton généré' do
      token = described_class.genere('compte-123')

      expect(described_class.compte_id(token)).to eq('compte-123')
    end

    it 'retourne nil pour un jeton invalide' do
      expect(described_class.compte_id('jeton-invalide')).to be_nil
    end

    it 'retourne nil pour un jeton expiré' do
      token = nil
      Timecop.freeze(Time.zone.now) { token = described_class.genere('compte-123') }

      Timecop.freeze(Time.zone.now + described_class::DUREE_VALIDITE + 1.minute) do
        expect(described_class.compte_id(token)).to be_nil
      end
    end
  end
end
