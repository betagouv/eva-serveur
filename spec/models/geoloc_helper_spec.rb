require 'rails_helper'

describe GeolocHelper, type: :model do
  it { expect(described_class.cherche_region(nil)).to be_nil }
  it { expect(described_class.cherche_region('99999')).to be_nil }
  it { expect(described_class.cherche_region('non_communique')).to be_nil }

  it "retourne la region d'un code postal" do
    mock_reponse_typhoeus('https://geo.api.gouv.fr/departements/45',
                          { codeRegion: 24 })

    mock_reponse_typhoeus('https://geo.api.gouv.fr/regions/24',
                          { nom: 'Centre-Val de Loire' })

    expect(described_class.cherche_region('45300')).to eql('Centre-Val de Loire')
  end

  it 'retourne nil quand il trouve le département, mais pas la région' do
    mock_reponse_typhoeus('https://geo.api.gouv.fr/departements/45',
                          { codeRegion: 24 })

    expect(described_class.cherche_region('45300')).to be_nil
  end
end
