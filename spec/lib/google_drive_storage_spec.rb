# frozen_string_literal: true

require 'rails_helper'
require 'google_drive_storage'

describe GoogleDriveStorage do
  let(:mock_session) { instance_double(GoogleDrive::Session) }
  let(:mock_file) { instance_double(GoogleDrive::File, name: 'programme_tele.png') }
  let(:mock_folder) { instance_double(GoogleDrive::Collection) }
  let(:folder_id) { 'fake-folder-id' }
  let(:file_name) { 'programme_tele.png' }
  let(:storage) { described_class.new }

  before do
    allow(GoogleDrive::Session).to receive(:from_service_account_key).and_return(mock_session)
    allow(storage).to receive(:recupere_session).and_return(mock_session)
  end

  describe '#recupere_session' do
    it "s'authentifie avec succès et retourne une session valide" do
      expect(storage.recupere_session).to eq(mock_session)
    end
  end

  describe '#recupere_fichier' do
    context 'quand le fichier existe' do
      before do
        allow(storage.session).to receive(:file_by_title).with(file_name).and_return(mock_file)
      end

      it 'retourne le fichier' do
        file = storage.recupere_fichier(folder_id, file_name)
        expect(file).not_to be_nil
        expect(file.name).to eq(file_name)
      end
    end

    context "quand le fichier n'existe pas" do
      before do
        allow(storage.session).to receive(:file_by_title).with(file_name).and_return(nil)
      end

      it 'retourne une erreur' do
        expect { storage.recupere_fichier(folder_id, file_name) }.to raise_error(
          GoogleDriveStorage::Error,
          "Fichier '#{file_name}' n'existe pas dans le dossier '#{folder_id}'"
        )
      end
    end
  end

  describe '#existe_dossier?' do
    context 'quand le dossier existe' do
      before do
        allow(storage.session).to receive(:collection_by_id).with(folder_id).and_return(mock_folder)
      end

      it 'retourne true' do
        expect(storage.existe_dossier?(folder_id)).to be true
      end
    end

    context "quand le dossier n'existe pas" do
      let!(:error) { Google::Apis::ClientError.new("notFound: File not found: #{folder_id}") }

      before do
        allow(storage.session).to receive(:collection_by_id).with(folder_id).and_raise(error)
      end

      it 'renvoie une erreur' do
        expect { storage.existe_dossier?(folder_id) }.to raise_error(
          GoogleDriveStorage::Error,
          "Le dossier avec l'id '#{folder_id}' n'est pas accessible : " \
          "notFound: File not found: #{folder_id}"
        )
      end
    end
  end
end
