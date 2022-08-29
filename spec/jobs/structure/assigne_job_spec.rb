# frozen_string_literal: true

require 'rails_helper'

describe Structure::AssigneRegionJob, type: :job do
  let!(:structure) { create :structure, code_postal: '92100' }

  before do
    structure.update(region: nil)
    Geocoder::Lookup::Test.add_stub(
      '92100', [
        {
          'coordinates' => [40.7143528, -74.0059731],
          'state' => 'Île-de-France'
        }
      ]
    )
    Structure::AssigneRegionJob.perform_now
    structure.reload
  end

  it { expect(structure.region).to eq 'Île-de-France' }
end
