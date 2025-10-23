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

      before do
        sign_in compte_admin_administratif
        get :new
      end

      it "retourne uniquement les comptes des structures locales filles du compte connecté" do
        comptes = controller.send(:comptes_structures_filles)

        expect(comptes).to include(compte_locale_fille)
        expect(comptes).not_to include(compte_admin_fille)
        expect(comptes).not_to include(compte_independant)
        expect(comptes).not_to include(compte_admin_administratif)
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
end
