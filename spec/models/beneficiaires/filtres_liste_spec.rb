require "rails_helper"

describe Beneficiaires::FiltresListe do
  let(:compte) { build :compte_conseiller }

  def filtres(parametres)
    described_class.new(ActionController::Parameters.new(parametres), compte)
  end

  it "se contente de paramètres absents" do
    filtres_vides = described_class.new(nil, compte)

    expect(filtres_vides.recherche).to be_nil
    expect(filtres_vides.statuts).to eq []
    expect(filtres_vides.nombre_bornes_creation).to eq 0
    expect(filtres_vides.campagne).to be_nil
  end

  it "lit la recherche" do
    expect(filtres(recherche: "ali").recherche).to eq "ali"
  end

  describe "suivi" do
    it "ne garde que les statuts choisis" do
      expect(filtres(statut_suivi_in: [ "", "a_renseigner" ]).statuts).to eq [ "a_renseigner" ]
    end

    it "propose les statuts filtrables avec leur libellé" do
      expect(filtres({}).options_statuts.first)
        .to eq [ I18n.t("statut_suivi.a_renseigner"), "a_renseigner" ]
    end
  end

  describe "date de création" do
    subject(:periode) do
      filtres(created_at_gteq_datetime: "2025-01-01", created_at_lteq_datetime: "")
    end

    it "lit les deux bornes" do
      expect(periode.creation_debut).to eq "2025-01-01"
      expect(periode.creation_fin).to eq ""
    end

    it "compte les bornes renseignées" do
      expect(periode.nombre_bornes_creation).to eq 1
    end
  end

  describe "campagne" do
    let(:campagne) { create :campagne }

    it "retrouve la campagne choisie" do
      choix = filtres(evaluations_campagne_id_eq: campagne.id)

      expect(choix.campagne_id).to eq campagne.id
      expect(choix.campagne).to eq campagne
    end
  end

  describe "structure" do
    let(:structure) { create :structure_locale }

    it "retrouve la structure choisie" do
      choix = filtres(evaluations_campagne_compte_structure_id_eq: structure.id)

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
