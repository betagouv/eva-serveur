# frozen_string_literal: true

require 'rails_helper'

describe 'questions:attache_assets' do
  include_context 'rake'
  let(:logger) { RakeLogger.logger }
  let!(:question) { create :question_qcm, nom_technique: 'lodi_1' }
  let!(:transcription) { create :transcription, question_id: question.id, categorie: :intitule }
  let!(:choix) { create :choix, :bon, question_id: question.id, nom_technique: 'LOdi_couverture' }
  let!(:choix2) do
    create :choix, :mauvais, question_id: question.id, nom_technique: 'LOdi_drap'
  end

  context 'appellé avec une dossier id inconnu' do
    let(:error_message) do
      "Le dossier avec l'id 'inconnue' n'est pas accessible : " \
        'notFound: File not found: inconnue.'
    end

    before do
      ENV['DOSSIER_ID'] = 'inconnue'
      drive = instance_double(GoogleDriveStorage)
      allow(GoogleDriveStorage).to receive(:new).and_return(drive)
      allow(drive).to receive(:existe_dossier?).with('inconnue').and_raise(
        GoogleDriveStorage::Error, error_message
      )
      subject.reenable
    end

    it do
      expect(logger).to receive(:error).with(error_message)
      expect(logger).to receive(:info).exactly(0).times
      subject.invoke
    end
  end

  context 'appellé sans dossier id' do
    it do
      ENV['DOSSIER_ID'] = nil
      expect(logger).to receive(:error)
        .with("La variable d'environnement DOSSIER_ID est manquante")
      expect(logger).to receive(:info)
        .with('Usage : rake questions:attache_assets DOSSIER_ID=<dossier_id>')
      subject.invoke
    end
  end

  context 'appellé avec un dossier id valide' do
    let(:fake_files) do
      [
        instance_double(GoogleDrive::File, name: 'illustration.png',
                                           download_to_string: 'fake_content'),
        instance_double(GoogleDrive::File, name: 'lodi_1.mp3',
                                           download_to_string: 'fake_content'),
        instance_double(GoogleDrive::File, name: 'LOdi_couverture.mp3',
                                           download_to_string: 'fake_content'),
        instance_double(GoogleDrive::File, name: 'LOdi_drap.mp3',
                                           download_to_string: 'fake_content')
      ]
    end

    before do
      ENV['DOSSIER_ID'] = 'fake-dossier-id'
      drive = instance_double(GoogleDriveStorage)
      allow(GoogleDriveStorage).to receive(:new).and_return(drive)
      allow(drive).to receive(:existe_dossier?).with('fake-dossier-id').and_return(true)

      file_names = ['programme_tele.png', 'lodi_1.mp3', 'LOdi_couverture.mp3', 'LOdi_drap.mp3']
      file_names.each_with_index do |file_name, index|
        allow(drive).to receive(:recupere_fichier).with('fake-dossier-id',
                                                        file_name).and_return(fake_files[index])
      end

      subject.reenable
      subject.invoke
    end

    context "attache l'illustration à la question correspondante" do
      it { expect(question.reload.illustration.attached?).to be true }
    end

    context "attache l'audio à l'intitulé de la question correspondante" do
      it { expect(question.reload.transcription_intitule.audio.attached?).to be true }
    end

    context "attache l'audio aux choix de la question correspondante" do
      it { expect(question.reload.choix[0].audio.attached?).to be true }
      it { expect(question.reload.choix[1].audio.attached?).to be true }
    end
  end
end
