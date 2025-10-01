shared_context 'import' do
  include ActionDispatch::TestProcess::FixtureFile

  subject(:service) do
    "ImportExport::Questions::Import::#{type}".constantize.new(headers)
  end

  let(:headers) do
    ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[type]
  end

  before do
    # Stub les URLS présentes dans les fichiers de test XLS
    stub_request(:get, 'https://serveur/choix1.mp3')
    stub_request(:get, 'https://serveur/choix2.mp3')
    stub_request(:get, 'https://serveur/consigne.mp3')
    stub_request(:get, 'https://serveur/illustration.png')
    stub_request(:get, 'https://serveur/image_au_clic.svg')
    stub_request(:get, 'https://serveur/intitule.mp3')
    stub_request(:get, 'https://serveur/reponse1.png')
    stub_request(:get, 'https://serveur/reponse2.png')
    stub_request(:get, 'https://serveur/zone_clicable.svg')
      .to_return(status: 200,
                 body: Rails.root.join('spec/support/zone-clicable-valide.svg').read)
    stub_request(:get, 'https://serveur/zone_depot.svg')
      .to_return(status: 200,
                 body: Rails.root.join('spec/support/N1Pse1-zone-depot-valide.svg').read)
  end
end
