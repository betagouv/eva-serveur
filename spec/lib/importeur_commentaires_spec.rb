# frozen_string_literal: true

require 'rails_helper'
require 'importeur_commentaires'

describe ImporteurCommentaires do
  let(:evabot) { create :compte, :superadmin, email: Eva::EMAIL_SUPPORT }

  context 'commentaire sur un compte existant' do
    let(:structure) { create :structure }
    let!(:compte) { create :compte, email: 'mon-conseiller@milo.fr', structure: structure }
    let(:ligne) { { utilisation_eva: 'Mon utilisation', mail: 'mon-conseiller@milo.fr' } }

    it do
      expect { ImporteurCommentaires.importe(ligne, evabot) }
        .to(change { ActiveAdmin::Comment.count })
      commentaire = ActiveAdmin::Comment.last
      expect(commentaire.resource).to eq structure
      expect(commentaire.body).to eq 'Mon utilisation'
    end

    context 'importe les notes' do
      let(:ligne) { { notes: 'Mes notes', mail: 'mon-conseiller@milo.fr' } }
      before { ImporteurCommentaires.importe(ligne, evabot) }
      it { expect(ActiveAdmin::Comment.last.body).to eq 'Mes notes' }
    end

    context 'ne duplique pas les commentaires pour permettre de réimporter si besoin' do
      before { ImporteurCommentaires.importe(ligne, evabot) }
      it do
        expect { ImporteurCommentaires.importe(ligne, evabot) }
          .to_not(change { ActiveAdmin::Comment.count })
      end
    end
  end

  context 'ignore un compte inexistant' do
    let(:logger) { RakeLogger.logger }
    let(:ligne) { { utilisation_eva: 'Mon usage', mail: 'inconnu@milo.fr' } }

    it do
      expect(logger).to receive(:info)
        .with('Commentaire ignoré pour le compte inconnu : inconnu@milo.fr')
      expect { ImporteurCommentaires.importe(ligne, evabot) }
        .to_not(change { ActiveAdmin::Comment.count })
    end
  end
end
