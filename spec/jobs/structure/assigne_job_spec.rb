# frozen_string_literal: true

require 'rails_helper'

describe Structure::AssigneRegionJob, type: :job do
  let!(:structure) { create :structure, code_postal: '92100' }

  before do
    structure.update(region: nil)
    allow(RestClient).to receive(:get)
      .with('https://geo.api.gouv.fr/departements/92')
      .and_return({ codeRegion: 11 }.to_json)
    allow(RestClient).to receive(:get)
      .with('https://geo.api.gouv.fr/regions/11')
      .and_return({ nom: 'Île-de-France' }.to_json)
    Structure::AssigneRegionJob.perform_now
    structure.reload
  end

  it { expect(structure.region).to eq 'Île-de-France' }
end
