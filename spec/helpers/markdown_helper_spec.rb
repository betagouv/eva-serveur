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
      let(:contenu) { '**évaluer les compétences**' }

      it 'retourne le contenu traduit en html' do
        expect(helper.md(contenu)).to match('<p><strong>évaluer les compétences</strong></p>')
      end
    end
  end
end
