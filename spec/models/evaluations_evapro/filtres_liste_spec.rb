require "rails_helper"

describe EvaluationsEvapro::FiltresListe do
  let(:compte) { build :compte_conseiller }

  def filtres(parametres = {})
    described_class.new(ActionController::Parameters.new(parametres), compte)
  end

  it "se contente de paramètres absents" do
    filtres_vides = described_class.new(nil, compte)

    expect(filtres_vides.recherche).to be_nil
    expect(filtres_vides.debut.debut).to be_nil
    expect(filtres_vides.structure.libelle).to be_nil
  end

  it "lit la recherche" do
    expect(filtres(recherche: "ali").recherche).to eq "ali"
  end

  it "lit la période de début" do
    expect(filtres(debutee_le_lteq_datetime: "2025-01-31").debut.fin).to eq "2025-01-31"
  end

  describe "structure" do
    let(:structure) { create :structure_locale }

    it "retrouve la structure choisie" do
      choix = filtres(campagne_compte_structure_id_eq: structure.id)

      expect(choix.structure.enregistrement).to eq structure
    end

    it "n'est proposée qu'aux comptes ANLCI ou administratifs" do
      expect(filtres.filtre_structure?).to be false

      allow(compte).to receive(:anlci?).and_return(true)
      expect(filtres.filtre_structure?).to be true
    end
  end
end
