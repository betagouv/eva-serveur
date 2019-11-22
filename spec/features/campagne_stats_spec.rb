# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Campagne Stats', type: :feature do
  let(:compte_organisation) { create :compte_organisation, email: 'orga@eva.fr' }
  let!(:campagne) do
    create :campagne, libelle: 'Rouen 30 mars', code: 'A5ROUEN', compte: compte_organisation
  end
  let!(:evaluation) { create :evaluation, nom: 'Roger', campagne: campagne }
  let(:restitution_inventaire) do
    double(
      situation: Situation.new(nom_technique: 'inventaire'),
      efficience: 2,
      temps_total: 3,
      nombre_ouverture_contenant: 4,
      nombre_essais_validation: 5
    )
  end
  let(:restitution_controle) do
    double(
      situation: Situation.new(nom_technique: 'controle'),
      efficience: 6,
      nombre_bien_placees: 7,
      nombre_mal_placees: 8,
      nombre_non_triees: 9
    )
  end
  let(:restitution_tri) do
    double(
      situation: Situation.new(nom_technique: 'tri'),
      efficience: 10,
      temps_total: 11,
      nombre_bien_placees: 12,
      nombre_mal_placees: 13
    )
  end

  describe 'index' do
    before do
      restitution_globale = double(efficience: 1,
                                   restitutions: [
                                     restitution_inventaire,
                                     restitution_controle,
                                     restitution_tri
                                   ])
      expect(restitution_globale).to receive(:efficience).and_return(1)
      expect(FabriqueRestitution).to receive(:restitution_globale).and_return(restitution_globale)
      connecte compte_organisation
      visit admin_campagne_stats_path
    end

    it do
      expect(page).to have_content 'Roger'
      content = all(:css, 'tbody tr td').map(&:text)[2..]
      expect(content).to eql(%w[1 2 3 4 5 6 7 8 9 10 11 12 13])
    end
  end
end
