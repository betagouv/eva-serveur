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

  describe "#comptes_structures_filles" do
    context "lors de la création d'une campagne par un compte administratif" do
      let!(:structure_administrative) { create :structure_administrative }
      let!(:compte_admin_administratif) {
 create :compte_admin, structure: structure_administrative }

      let!(:structure_locale_fille) {
 create :structure_locale, nom: "Structure Locale Fille",
structure_referente: structure_administrative }
      let!(:admin_locale_fille) { create :compte_admin, structure: structure_locale_fille }
      let!(:compte_locale_fille) {
 create :compte_conseiller, nom: "Durand", prenom: "Alice", structure: structure_locale_fille }

      let!(:structure_administrative_fille) {
 create :structure_administrative, nom: "Structure Admin Fille",
structure_referente: structure_administrative }
      let!(:admin_admin_fille) { create :compte_admin, structure: structure_administrative_fille }
      let!(:compte_admin_fille) {
 create :compte_conseiller, nom: "Bernard", prenom: "Bob",
structure: structure_administrative_fille }

      let!(:structure_independante) { create :structure_locale, nom: "Structure Indépendante" }
      let!(:admin_independante) { create :compte_admin, structure: structure_independante }
      let!(:compte_independant) {
 create :compte_conseiller, nom: "Moreau", prenom: "Claire", structure: structure_independante }
      let!(:compte_refuse) { create :compte_conseiller, :refusee, nom: "Refuse", prenom: "Paul",
                                    structure: structure_locale_fille }

      before do
        sign_in compte_admin_administratif
        get :new
      end

      it "retourne uniquement les comptes des SF locales, non refusé, du compte connecté" do
        comptes = controller.send(:comptes_structures_filles)

        expect(comptes).to include(compte_locale_fille)
        expect(comptes).not_to include(compte_admin_fille)
        expect(comptes).not_to include(compte_independant)
        expect(comptes).not_to include(compte_admin_administratif)
        expect(comptes).not_to include(compte_refuse)
      end
    end

    context "quand le compte connecté n'a pas de structure" do
      let!(:compte_sans_structure) {
 create :compte_conseiller, structure: nil, statut_validation: :en_attente }

      before do
        sign_in compte_sans_structure
        get :new
      end

      it "retourne une relation vide" do
        comptes = controller.send(:comptes_structures_filles)

        expect(comptes).to be_empty
        expect(comptes).to be_a(ActiveRecord::Relation)
      end
    end
  end

  describe "assigne_valeurs_par_defaut" do
    context "quand le compte est administratif" do
      let(:structure_administrative) { create :structure_administrative }
      let(:compte_administratif) { create :compte_admin, structure: structure_administrative }

      before do
        sign_in compte_administratif
      end

      it "ne pré-remplit pas le champ compte_id dans les params" do
        get :new
        expect(controller.params[:campagne][:compte_id]).to be_nil
      end
    end

    context "quand le compte n'est pas administratif" do
      it "pré-remplit le champ compte_id avec le compte courant dans les params" do
        get :new
        expect(controller.params[:campagne][:compte_id]).to eq(compte_connecte.id)
      end
    end
  end

  describe "tri par structure" do
    let(:structure_administrative) { create :structure_administrative }
    let(:structure_aaa) do
      create :structure_locale, nom: "aaa Structure", structure_referente: structure_administrative
    end
    let(:structure_bbb) do
      create :structure_locale, nom: "BBB Structure", structure_referente: structure_administrative
    end
    let(:structure_ccc) do
      create :structure_locale, nom: "CCC Structure", structure_referente: structure_administrative
    end
    let(:compte_structure_aaa) { create :compte_admin, structure: structure_aaa }
    let(:compte_structure_bbb) { create :compte_admin, structure: structure_bbb }
    let(:compte_structure_ccc) { create :compte_admin, structure: structure_ccc }
    let!(:campagne_structure_aaa) do
      create :campagne, libelle: "Campagne aaa", compte: compte_structure_aaa
    end
    let!(:campagne_structure_bbb) do
      create :campagne, libelle: "Campagne BBB", compte: compte_structure_bbb
    end
    let!(:campagne_structure_ccc) do
      create :campagne, libelle: "Campagne CCC", compte: compte_structure_ccc
    end

    context "avec un compte administratif" do
      let(:compte_administratif) { create :compte_admin, structure: structure_administrative }

      before do
        sign_in compte_administratif
      end

      it "permet de trier par nom de structure sans erreur SQL" do
        expect {
          get :index, params: { order: "lower_structures.nom_asc" }
        }.not_to raise_error

        expect(response).to have_http_status(:success)
      end

      it "trie les campagnes par nom de structure en ordre croissant (insensible à la casse)" do
        get :index, params: { order: "lower_structures.nom_asc" }

        expect(response).to have_http_status(:success)

        # Vérifie que toutes les campagnes sont présentes
        expect(response.body).to include(campagne_structure_aaa.libelle)
        expect(response.body).to include(campagne_structure_bbb.libelle)
        expect(response.body).to include(campagne_structure_ccc.libelle)

        # Vérifie l'ordre (insensible à la casse : aaa < BBB < CCC)
        position_aaa = response.body.index(campagne_structure_aaa.libelle)
        position_bbb = response.body.index(campagne_structure_bbb.libelle)
        position_ccc = response.body.index(campagne_structure_ccc.libelle)

        positions = [ position_aaa, position_bbb, position_ccc ]
        expect(positions).to eq(positions.sort)
      end

      it "trie les campagnes par nom de structure en ordre décroissant (insensible à la casse)" do
        get :index, params: { order: "lower_structures.nom_desc" }

        expect(response).to have_http_status(:success)

        # Vérifie l'ordre inverse (CCC > BBB > aaa)
        position_aaa = response.body.index(campagne_structure_aaa.libelle)
        position_bbb = response.body.index(campagne_structure_bbb.libelle)
        position_ccc = response.body.index(campagne_structure_ccc.libelle)

        positions = [ position_ccc, position_bbb, position_aaa ]
        expect(positions).to eq(positions.sort)
      end
    end

    context "avec un compte ANLCI" do
      let(:compte_anlci) { create :compte_charge_mission_regionale, structure: structure_aaa }

      before do
        sign_in compte_anlci
      end

      it "permet de trier par nom de structure sans erreur SQL" do
        expect {
          get :index, params: { order: "lower_structures.nom_asc" }
        }.not_to raise_error

        expect(response).to have_http_status(:success)
      end
    end
  end
end
