# frozen_string_literal: true

require 'rails_helper'
require 'google_drive_storage'

describe GoogleDriveStorage do
  let(:mock_session) { instance_double(GoogleDrive::Session) }
  let(:mock_folder) { instance_double(GoogleDrive::Collection) }
  let(:mock_file) { instance_double(GoogleDrive::File, name: 'programme_tele.png') }
  let(:folder_id) { 'fake-folder-id' }
  let(:file_name) { 'programme_tele.png' }

  before do
    allow(described_class).to receive(:recupere_session).and_return(mock_session)
  end

  describe '.recupere_session' do
    it "s'authentifie avec succès et retourne une session valide" do
      expect(described_class.recupere_session).to eq(mock_session)
    end
  end

  describe '.recupere_fichier' do
    before do
      allow(mock_session).to receive(:collection_by_id).with(folder_id).and_return(mock_folder)
    end

    context 'quand le fichier existe dans le dossier' do
      before do
        allow(mock_folder).to receive(:files).and_return([mock_file])
      end

      it 'retourne le fichier' do
        file = described_class.recupere_fichier(folder_id, file_name)
        expect(file).not_to be_nil
        expect(file.name).to eq(file_name)
      end
    end

    context "quand le fichier n'existe pas dans le dossier" do
      before do
        allow(mock_folder).to receive(:files).and_return([])
      end

      it 'retourne une erreur' do
        expect { described_class.recupere_fichier(folder_id, file_name) }.to raise_error(
          "Fichier '#{file_name}' n'existe pas dans le dossier '#{folder_id}'"
        )
      end
    end
  end

  describe '.existe_dossier?' do
    context 'quand le dossier existe' do
      before do
        allow(mock_session).to receive(:collection_by_id).with(folder_id).and_return(mock_folder)
      end

      it 'retourne true' do
        expect(described_class).to be_existe_dossier(folder_id)
      end
    end

    context "quand le dossier n'existe pas" do
      let!(:error) { Google::Apis::ClientError.new("notFound: File not found: #{folder_id}") }

      before do
        allow(mock_session).to receive(:collection_by_id).with(folder_id).and_raise(error)
      end

      it 'renvoie une erreur' do
        expect { described_class.existe_dossier?(folder_id) }.to raise_error(
          GoogleDriveStorage::Error,
          "Le dossier avec l'id '#{folder_id}' n'est pas accessible : " \
          "notFound: File not found: #{folder_id}"
        )
      end
    end
  end
end
