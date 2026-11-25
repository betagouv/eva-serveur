require "rails_helper"

describe Comptes::FiltresListe do
  let(:compte) { build :compte_conseiller }

  def filtres(parametres, options = {})
    described_class.new(ActionController::Parameters.new(parametres), compte,
                        gestion: options.fetch(:gestion, false),
                        activation: options[:activation])
  end

  it "se contente de paramètres absents" do
    filtres_vides = described_class.new(nil, compte, gestion: false, activation: nil)

    expect(filtres_vides.recherche).to be_nil
    expect(filtres_vides.statuts_validation).to eq []
    expect(filtres_vides.roles).to eq []
    expect(filtres_vides.creation.debut).to be_nil
    expect(filtres_vides.structure.libelle).to be_nil
  end

  it "lit la recherche" do
    expect(filtres(recherche: "durand").recherche).to eq "durand"
  end

  describe "statut d'accès" do
    it "ne garde que les statuts choisis" do
      expect(filtres(statut_validation_in: [ "", "0" ]).statuts_validation).to eq [ "0" ]
    end

    it "propose les statuts avec leur libellé" do
      expect(filtres({}).options_statuts_validation.first)
        .to eq [ Compte.human_enum_name(:statut_validation, "en_attente"), 0 ]
    end
  end

  it "ne garde que les rôles choisis" do
    expect(filtres(role_in: [ "", "admin" ]).roles).to eq [ "admin" ]
  end

  describe "structure" do
    let(:structure) { create :structure_locale }

    it "retrouve la structure choisie" do
      choix = filtres(structure_id_eq: structure.id)

      expect(choix.structure.id).to eq structure.id
      expect(choix.structure.enregistrement).to eq structure
    end

    it "n'est proposée qu'aux comptes ANLCI ou administratifs" do
      expect(filtres({}).filtre_structure?).to be false

      allow(compte).to receive(:anlci?).and_return(true)
      expect(filtres({}).filtre_structure?).to be true
    end
  end

  describe "filtres de gestion" do
    it "ne sont proposés qu'aux comptes qui gèrent les comptes" do
      expect(filtres({}).filtres_gestion?).to be false
      expect(filtres({}, gestion: true).filtres_gestion?).to be true
    end

    it "lisent le type et la région de la structure" do
      choix = filtres(structure_type_structure_eq: "mission_locale",
                      structure_region_eq: "Bretagne")

      expect(choix.type_structure).to eq "mission_locale"
      expect(choix.region).to eq "Bretagne"
    end

    it "proposent les régions des structures" do
      create :structure_locale, region: "Bretagne"

      expect(filtres({}).options_regions).to include("Bretagne")
    end
  end

  describe "critères de structure" do
    it "sont proposés aux comptes ANLCI ou administratifs, ou qui gèrent les comptes" do
      expect(filtres({}).criteres_structure?).to be false
      expect(filtres({}, gestion: true).criteres_structure?).to be true

      allow(compte).to receive(:anlci?).and_return(true)
      expect(filtres({}).criteres_structure?).to be true
    end
  end

  describe "activation de la structure" do
    it "lit le statut choisi" do
      expect(filtres({}, activation: "actives").activation).to eq "actives"
    end

    it "propose chaque statut avec son libellé et son nombre de comptes" do
      options = filtres({}).options_activation("actives" => 3)

      expect(options).to include [ "#{I18n.t('active_admin.scopes.actives')} (3)", "actives" ]
    end
  end
end
