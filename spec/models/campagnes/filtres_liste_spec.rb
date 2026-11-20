require "rails_helper"

describe Campagnes::FiltresListe do
  let(:compte) { build :compte_conseiller }

  def filtres(parametres)
    described_class.new(ActionController::Parameters.new(parametres), compte)
  end

  it "se contente de paramètres absents" do
    filtres_vides = described_class.new(nil, compte)

    expect(filtres_vides.recherche).to be_nil
    expect(filtres_vides.situations).to eq []
    expect(filtres_vides.creation.nombre_bornes).to eq 0
    expect(filtres_vides.compte_choisi).to be_nil
    expect(filtres_vides.structure).to be_nil
  end

  it "lit la recherche" do
    expect(filtres(recherche: "paris").recherche).to eq "paris"
  end

  describe "situations" do
    let!(:situation) { create :situation_inventaire }

    it "ne garde que les situations choisies" do
      choix = filtres(situations_configurations_situation_id_in: [ "", situation.id ])

      expect(choix.situations).to eq [ situation.id ]
    end

    it "propose les situations par libellé" do
      expect(filtres({}).options_situations).to include [ situation.libelle, situation.id ]
    end
  end

  it "lit la période de création" do
    expect(filtres(created_at_gteq_datetime: "2025-01-01").creation.debut).to eq "2025-01-01"
  end

  describe "compte" do
    let(:autre_compte) { create :compte_conseiller, :structure_avec_admin }

    it "retrouve le compte choisi" do
      choix = filtres(compte_id_eq: autre_compte.id)

      expect(choix.compte_id).to eq autre_compte.id
      expect(choix.compte_choisi).to eq autre_compte
    end
  end

  describe "structure" do
    let(:structure) { create :structure_locale }

    it "retrouve la structure choisie" do
      choix = filtres(compte_structure_id_eq: structure.id)

      expect(choix.structure_id).to eq structure.id
      expect(choix.structure).to eq structure
    end

    it "n'est proposée qu'aux comptes ANLCI ou administratifs" do
      expect(filtres({}).filtre_structure?).to be false

      allow(compte).to receive(:anlci?).and_return(true)
      expect(filtres({}).filtre_structure?).to be true
    end
  end
end
