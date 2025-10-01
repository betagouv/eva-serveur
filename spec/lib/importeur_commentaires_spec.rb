require 'rails_helper'
require 'importeur_commentaires'

describe ImporteurCommentaires do
  let(:evabot) { create :compte, :superadmin, email: Eva::EMAIL_SUPPORT }
  let(:logger) { RakeLogger.logger }

  context 'commentaire sur un compte existant' do
    let(:structure) { create :structure_locale }
    let!(:compte) { create :compte, email: 'mon-conseiller@milo.fr', structure: structure }
    let(:ligne) { { utilisation_eva: 'Mon utilisation', mail: 'mon-conseiller@milo.fr' } }

    before do
      allow(logger).to receive(:info)
    end

    it do
      expect(logger).to receive(:info)
        .with('Importe : mon-conseiller@milo.fr,Mon utilisation,')
      expect { described_class.importe(ligne, evabot) }
        .to(change(ActiveAdmin::Comment, :count))
      commentaire = ActiveAdmin::Comment.last
      expect(commentaire.resource).to eq structure
      expect(commentaire.body).to eq 'utilisation_eva : Mon utilisation'
    end

    context 'importe les notes' do
      let(:ligne) { { notes: 'Mes notes', mail: 'mon-conseiller@milo.fr' } }

      before { described_class.importe(ligne, evabot) }

      it { expect(ActiveAdmin::Comment.last.body).to eq 'notes : Mes notes' }
    end

    context 'ignore les lignes sans aucun commentaire' do
      let(:ligne) { { notes: ' ', utilisation_eva: '', mail: 'mon-conseiller@milo.fr' } }

      it do
        expect(logger).to receive(:info).exactly(0).times
        expect { described_class.importe(ligne, evabot) }
          .not_to(change(ActiveAdmin::Comment, :count))
      end
    end

    context 'ne duplique pas les commentaires pour permettre de réimporter si besoin' do
      before { described_class.importe(ligne, evabot) }

      it do
        expect { described_class.importe(ligne, evabot) }
          .not_to(change(ActiveAdmin::Comment, :count))
      end
    end
  end

  context 'ignore un compte inexistant' do
    let(:ligne) { { utilisation_eva: 'Mon usage', notes: 'une note', mail: 'inconnu@milo.fr' } }

    it do
      expect(logger).to receive(:warn)
        .with('Commentaire ignoré pour le compte inconnu : inconnu@milo.fr,Mon usage,une note')
      expect { described_class.importe(ligne, evabot) }
        .not_to(change(ActiveAdmin::Comment, :count))
    end
  end
end
