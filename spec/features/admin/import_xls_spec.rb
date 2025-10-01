require 'rails_helper'

describe 'Import XLS', type: :feature do
  let!(:compte) { create :compte_superadmin }

  before { connecte(compte) }

  it 'importe un fichier XLS de type QuestionGlisserDeposer' do
    visit admin_import_xls_path(type: 'QuestionGlisserDeposer', model: 'question')

    stub_request(:get, %r{^https://stockagepreprod\.eva\.beta\.gouv\.fr(/.*)?$})
      .to_return(status: 200, body: '', headers: {})

    chemin_fichier = Rails.root.join('spec/support/import_question_glisser_deposer.xls').to_s
    attach_file('file_xls', chemin_fichier)
    click_button 'Importer le fichier'

    expect(page).to have_http_status(200)
  end

  it 'importe un fichier XLS pour un questionnaire' do
    visit admin_import_xls_path(model: 'questionnaire')

    chemin_fichier = Rails.root.join('spec/support/import_questionnaire.xls').to_s
    attach_file('file_xls', chemin_fichier)
    click_button 'Importer le fichier'

    expect(page).to have_http_status(200)
    expect(Questionnaire.count).to eq(1)
  end
end
