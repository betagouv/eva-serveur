# frozen_string_literal: true

require 'rails_helper'

describe GeolocHelper, type: :model do
  it { expect(GeolocHelper.cherche_region(nil)).to be(nil) }
  it { expect(GeolocHelper.cherche_region('99999')).to be(nil) }
  it { expect(GeolocHelper.cherche_region('non_communique')).to be(nil) }
  it "retourne la region d'un code postal" do
    expect(RestClient).to receive(:get)
      .with('https://geo.api.gouv.fr/departements/45')
      .and_return({ codeRegion: 24 }.to_json)
    expect(RestClient).to receive(:get)
      .with('https://geo.api.gouv.fr/regions/24')
      .and_return({ nom: 'Centre-Val de Loire' }.to_json)
    expect(GeolocHelper.cherche_region('45300')).to eql('Centre-Val de Loire')
  end
end
