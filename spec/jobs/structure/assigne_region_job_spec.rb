require 'rails_helper'

describe Structure::AssigneRegionJob, type: :job do
  let!(:structure) { create :structure, code_postal: '92100' }

  before do
    structure.update(region: nil)

    mock_reponse_typhoeus(
      'https://geo.api.gouv.fr/communes?codePostal=92100&fields=code,centre,region',
      [ { code: '92012',
          centre: { type: 'Point', coordinates: [ 2.2380, 48.8979 ] },
          region: { nom: 'Île-de-France' } } ]
    )

    described_class.perform_now
  end

  it { expect(structure.reload.region).to eq 'Île-de-France' }
end
