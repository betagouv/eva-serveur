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
    let!(:actualite1) { create :actualite, titre: 'titre1' }
    let!(:actualite2) { create :actualite, titre: 'titre2' }
    let!(:actualite3) { create :actualite, titre: 'titre3' }

    it { expect(actualite1.recentes_sauf_moi(1)).to eql([actualite3]) }
    it { expect(actualite1.recentes_sauf_moi(3)).to eql([actualite3, actualite2]) }
    it { expect(actualite2.recentes_sauf_moi(3)).to eql([actualite3, actualite1]) }
  end

  describe '#tableau_de_bord' do
    let!(:actualite1) { create :actualite, titre: 'titre1' }
    let!(:actualite2) { create :actualite, titre: 'titre2' }
    let!(:actualite3) { create :actualite, titre: 'titre3' }
    let!(:compte_admin) { create :compte_admin }
    let(:compte_refuse) do
      create :compte_conseiller, structure: compte_admin.structure, statut_validation: :refusee
    end

    it 'affiche les actualités, la plus récente en premier' do
      ability = Ability.new(compte_admin)
      expect(described_class.tableau_de_bord(ability))
        .to eq [actualite3, actualite2, actualite1]
    end

    it "n'affiche aucune actualité aux comptes refusés" do
      ability = Ability.new(compte_refuse)
      expect(described_class.tableau_de_bord(ability)).to eq []
    end
  end
end
