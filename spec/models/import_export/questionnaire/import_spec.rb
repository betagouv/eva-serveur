require 'rails_helper'

describe ImportExport::Questionnaire::Import do
  include ActionDispatch::TestProcess::FixtureFile

  subject(:service) do
    described_class.new(headers)
  end

  let(:headers) do
    ImportExport::Questionnaire::ImportExportDonnees::HEADERS_ATTENDUS
  end

  describe 'avec un fichier valide' do
    let(:file) do
      file_fixture_upload('spec/support/import_questionnaire.xls', 'text/xls')
    end

    before do
      # Crée les questions dans un ordre aléatoire
      create(:question, nom_technique: 'N1Pse2')
      create(:question, nom_technique: 'N1Pse1')
      create(:question, nom_technique: 'N1Pse3')
    end

    it 'importe un nouveau questionnaire' do
      expect do
        service.import_from_xls(file)
      end.to change(Questionnaire, :count).by(1)

      questionnaire = Questionnaire.last
      expect(questionnaire.libelle).to eq 'Numératie 2024'
      expect(questionnaire.nom_technique).to eq 'numeratie_2024'
      expect(questionnaire.questions.map(&:nom_technique)).to eq %w[N1Pse1 N1Pse2 N1Pse3]
    end
  end

  describe 'avec un fichier invalide' do
    let(:file) do
      file_fixture_upload('spec/support/import_questionnaire_invalide.xls', 'text/xls')
    end

    it 'renvoie une erreur avec les headers manquants' do
      message = service.send(:message_erreur_headers)

      expect do
        service.import_from_xls(file)
      end.to raise_error(ImportExport::Questionnaire::Import::Error, message)
    end
  end

  describe 'avec un questionnaire soft-delete' do
    let(:file) do
      file_fixture_upload('spec/support/import_questionnaire.xls', 'text/xls')
    end

    before do
      create(:questionnaire, nom_technique: 'numeratie_2024', deleted_at: Time.zone.now)
    end

    it "retourne les messages d'erreur" do
      message = 'Erreur de validation à la ligne 0 : Nom technique est déjà utilisé(e)'

      expect do
        service.import_from_xls(file)
      end.to raise_error(ImportExport::ImportXls::Error, message)
    end
  end
end
