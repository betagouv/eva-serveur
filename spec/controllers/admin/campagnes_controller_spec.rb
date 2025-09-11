# frozen_string_literal: true

require 'rails_helper'

describe Admin::CampagnesController, type: :controller do
  render_views

  let(:structure_conseiller) { create :structure_locale }
  let!(:compte_connecte) { create :compte_admin, prenom: "Xavier", structure: structure_conseiller }

  before do
    sign_in compte_connecte
  end

  describe "#comptes_structure" do
    let!(:ma_campagne) { create :campagne, compte: compte_connecte }
    let!(:autre_compte) do
      create :compte_conseiller, nom: "Dupont", prenom: "Jean",
             structure: compte_connecte.structure
    end
    let!(:compte_autre_structure) do
      autre_structure = create :structure_locale
      create :compte_admin, nom: "Martin", prenom: "Pierre", structure: autre_structure
    end

    context "quand la campagne a un compte" do
      before { get :show, params: { id: ma_campagne.id } }

      it "retourne tous les comptes de la même structure ordonnés par prénom et nom" do
        comptes = controller.send(:comptes_structure)

        expect(comptes).to include(compte_connecte)
        expect(comptes).to include(autre_compte)
        expect(comptes).not_to include(compte_autre_structure)
        expect(comptes.map(&:prenom)).to eq([ "Jean", "Xavier" ])
      end
    end
  end
end
