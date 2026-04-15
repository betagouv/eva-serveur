require 'rails_helper'

describe GeolocHelper, type: :model do
  describe '.cherche_commune' do
    it { expect(described_class.cherche_commune(nil)).to be_nil }

    it "retourne le code commune, les coordonnées et la région d'un code postal" do
      mock_reponse_typhoeus(
        'https://geo.api.gouv.fr/communes?codePostal=45300&fields=code,centre,region',
        [ { code: '45273',
            centre: { type: 'Point', coordinates: [ 2.17, 48.17 ] },
            region: { nom: 'Centre-Val de Loire' } } ]
      )

      expect(described_class.cherche_commune('45300')).to eql({
        code_commune: '45273',
        latitude: 48.17,
        longitude: 2.17,
        region: 'Centre-Val de Loire'
      })
    end

    it 'retourne nil quand le code postal ne correspond à aucune commune' do
      mock_reponse_typhoeus(
        'https://geo.api.gouv.fr/communes?codePostal=99999&fields=code,centre,region',
        []
      )

      expect(described_class.cherche_commune('99999')).to be_nil
    end
  end
end
