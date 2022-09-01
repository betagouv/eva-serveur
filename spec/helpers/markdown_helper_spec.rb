# frozen_string_literal: true

require 'rails_helper'

describe MarkdownHelper do
  describe '#md' do
    context "quand il n'y a pas de contenu" do
      let(:contenu) { nil }

      it 'retourne une chaine vide' do
        expect(helper.md(contenu)).to eq ''
      end
    end

    context 'quand il y a un contenu' do
      let(:contenu) { '*évaluer les compétences*' }

      it 'retourne le contenu traduit en html' do
        expect(helper.md(contenu)).to match('<p><em>évaluer les compétences</em></p>')
      end
    end

    context 'quand il y a un contenu avec une phrase en gras' do
      let(:contenu) { '**évaluer les compétences** transversales' }

      it 'retourne le contenu traduit en html avec une font-weight customisé' do
        html =
          '<p><strong class="fw-semi-bold">évaluer les compétences</strong> transversales</p>'
        expect(helper.md(contenu)).to match(html)
      end
    end
  end
end
