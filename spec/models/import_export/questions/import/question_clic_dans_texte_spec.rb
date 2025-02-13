# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::Questions::Import::QuestionClicDansTexte do
  include ActionDispatch::TestProcess::FixtureFile

  subject(:service) do
    described_class.new(headers)
  end

  let(:type_qcm) { 'QuestionClicDansTexte' }
  let(:headers) do
    ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[type_qcm]
  end
  let(:file) do
    file_fixture_upload('spec/support/import_question_qcm.xls', 'text/xls')
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

  it 'importe les données spécifiques' do
    service.import_from_xls(file)
    question = Question.last
    expect(question.suffix_reponse).to eq 'suffixe'
    expect(question.reponse_placeholder).to eq 'placeholder'
    expect(question.type_saisie).to eq 'numerique'
    expect(question.texte_a_trous).to eq '<html>'
    expect(question.reponses.first.intitule).to eq '9'
    expect(question.reponses.first.nom_technique).to eq 'reponse1'
    expect(question.reponses.first.type_choix).to eq 'acceptable'
    expect(question.reponses.second.intitule).to eq '10'
    expect(question.reponses.second.nom_technique).to eq 'reponse2'
    expect(question.reponses.second.type_choix).to eq 'bon'
  end
end
