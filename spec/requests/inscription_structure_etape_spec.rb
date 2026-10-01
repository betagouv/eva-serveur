# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Inscription - Étape structure, selon l'étape du compte", type: :request do
  let(:siret) { "83386447300016" }
  let(:ma_structure) { create(:structure_locale, :avec_admin) }
  let(:autre_structure) { create(:structure_locale, :avec_admin) }

  before do
    # L'action "rejoindre" ne propose que les structures du même SIRET que
    # celle du compte : sans SIRET commun, elle serait refusée quelle que
    # soit l'étape, et ces tests ne prouveraient rien.
    ma_structure.update_columns(siret: siret)
    autre_structure.update_columns(siret: siret)
  end

  def rejoint_autre_structure
    patch inscription_structure_path,
          params: { action_type: "rejoindre", compte: { structure_id: autre_structure.id } }
  end

  context "quand le compte en est à l'assignation de structure" do
    # Cas nominal : le compte n'a pas encore de structure, celle-ci est
    # retrouvée à partir du SIRET saisi pendant l'inscription.
    let(:compte) do
      create(:compte_conseiller, :en_attente, structure: nil, siret: siret,
                                              etape_inscription: "assignation_structure")
    end

    before { sign_in compte }

    it "permet de rejoindre une autre structure du même SIRET" do
      rejoint_autre_structure

      expect(response).to redirect_to(admin_dashboard_path)
      expect(compte.reload.structure).to eq(autre_structure)
      expect(compte.etape_inscription).to eq("complet")
    end
  end

  context "quand l'inscription du compte est terminée" do
    let(:compte) do
      create(:compte_conseiller, structure: ma_structure, etape_inscription: "complet")
    end

    before { sign_in compte }

    it "ne permet pas de rejoindre une autre structure" do
      rejoint_autre_structure

      expect(response).to redirect_to(admin_dashboard_path)
      expect(compte.reload.structure).to eq(ma_structure)
    end

    it "n'affiche pas l'étape structure" do
      get inscription_structure_path

      expect(response).to redirect_to(admin_dashboard_path)
    end
  end

  context "quand le compte en est à la recherche de structure" do
    let(:compte) do
      create(:compte_conseiller, :en_attente, structure: nil, siret: siret,
                                              etape_inscription: "recherche_structure")
    end

    before { sign_in compte }

    it "renvoie vers la recherche de structure" do
      rejoint_autre_structure

      expect(response).to redirect_to(inscription_recherche_structure_path)
      expect(compte.reload.structure).to be_nil
    end
  end
end
