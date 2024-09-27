# frozen_string_literal: true

require 'rails_helper'

describe Structure::AssigneRegionJob, type: :job do
  let!(:structure) { create :structure, code_postal: '92100' }

  before do
    structure.update(region: nil)

    mock_reponse_typhoeus('https://geo.api.gouv.fr/departements/92',
                          { codeRegion: 11 })

    mock_reponse_typhoeus('https://geo.api.gouv.fr/regions/11',
                          { nom: 'Île-de-France' })

    described_class.perform_now
  end

  it { expect(structure.reload.region).to eq 'Île-de-France' }
end
