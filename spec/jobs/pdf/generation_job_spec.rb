require 'rails_helper'

describe Pdf::GenerationJob, type: :job do
  describe '#perform' do
    context 'quand la génération réussit' do
      it 'diffuse le contenu du pdf encodé en base64 et supprime le fichier local' do
        fichier = Tempfile.new([ 'test', '.pdf' ])
        fichier.write('contenu-pdf')
        fichier.close
        allow(Pdf::Generateur).to receive(:genere).and_return(fichier.path)
        allow(Pdf::GenerationChannel).to receive(:diffuse)

        described_class.perform_now('mon-token', '<html></html>', 'rapport.pdf')

        expect(Pdf::GenerationChannel).to have_received(:diffuse).with(
          'mon-token',
          statut: 'pret',
          nom_fichier: 'rapport.pdf',
          contenu_base64: Base64.strict_encode64('contenu-pdf')
        )
        expect(File.exist?(fichier.path)).to be false
      end
    end

    context "quand la génération échoue" do
      it 'diffuse un statut erreur' do
        allow(Pdf::Generateur).to receive(:genere).and_return(false)
        allow(Pdf::GenerationChannel).to receive(:diffuse)

        described_class.perform_now('mon-token', '<html></html>', 'rapport.pdf')

        expect(Pdf::GenerationChannel).to have_received(:diffuse)
          .with('mon-token', statut: 'erreur')
      end
    end
  end
end
