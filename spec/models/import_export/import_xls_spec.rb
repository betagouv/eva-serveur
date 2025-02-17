# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::ImportXls do
  describe('#telecharge_fichier') do
    let(:fichier) { double }

    describe('quand le fichier ne se télécharge pas') do
      before do
        allow(Down).to receive(:download).and_raise(Down::Error)
      end

      it "retourne un message d'erreur" do
        expect { described_class.telecharge_fichier('url_corrompue', 'N3Pim4') }
          .to raise_error(ImportExport::ImportXls::Error,
                          "Impossible de télécharger un fichier depuis l'url : url_corrompue")
      end
    end

    describe('quand le fichier se télécharge') do
      before do
        fichier_mp3 = File.open('spec/support/alcoolique.mp3')
        allow(Down).to receive(:download).and_return(fichier_mp3)
      end

      it "retrouve l'extention de fichier sur l'url" do
        expect(described_class.telecharge_fichier(
          'https://domain/ou0dfrctvwgt?filename=nom_fichier_audio.mp3', 'N3Pim4'
        )[:filename]).to eq('N3Pim4.mp3')
      end

      it "retrouve l'extention de fichier sur l'url même avec des noms pourris" do
        expect(described_class.telecharge_fichier(
          'https://domain/ljitfyamq9h8j?filename=N2Rpl1R1 D&K.mp3', 'N3Pim4'
        )[:filename]).to eq('N3Pim4.mp3')
      end

      it "retrouve le type de contenu en fonction de l'extension" do
        expect(described_class.telecharge_fichier(
          'https://domain/ou0dfrctvwgt?filename=nom_fichier_audio.mp3', 'N3Pim4'
        )[:content_type]).to eq('audio/mpeg')
        expect(described_class.telecharge_fichier(
          'https://domain/ou0dfrctvwgt?filename=nom_fichier.svg', 'N3Pim4'
        )[:content_type]).to eq('image/svg+xml')
      end
    end
  end
end
