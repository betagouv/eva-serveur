# frozen_string_literal: true

require 'rails_helper'

describe Actualite do
  it { is_expected.to validate_presence_of(:titre) }
  it { is_expected.to validate_presence_of(:contenu) }
  it { is_expected.to validate_presence_of(:categorie) }
  it { is_expected.to have_one(:illustration_attachment) }

  describe 'limite la taille du titre pour le tableau de bord' do
    it { is_expected.to validate_length_of(:titre).is_at_most(100) }
  end

  describe '#recentes_sauf_moi' do
    let!(:actualite3) { create :actualite, titre: 'titre3' }
    let!(:actualite2) { create :actualite, titre: 'titre2' }
    let!(:actualite1) { create :actualite, titre: 'titre1' }

    it { expect(actualite1.recentes_sauf_moi(1)).to eql([actualite2]) }
    it { expect(actualite1.recentes_sauf_moi(3)).to eql([actualite2, actualite3]) }
    it { expect(actualite2.recentes_sauf_moi(3)).to eql([actualite1, actualite3]) }
  end
end
