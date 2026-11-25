require "rails_helper"

describe EvaluationsEva::FiltresListe do
  let(:compte) { build :compte_conseiller }

  def filtres(parametres = {}, scope = nil)
    described_class.new(ActionController::Parameters.new(parametres), compte, scope: scope)
  end

  it "se contente de paramètres absents" do
    filtres_vides = described_class.new(nil, compte, scope: nil)

    expect(filtres_vides.recherche).to be_nil
    expect(filtres_vides.statuts).to eq []
    expect(filtres_vides.debut.debut).to be_nil
    expect(filtres_vides.campagne.libelle).to be_nil
    expect(filtres_vides.structure.libelle).to be_nil
    expect(filtres_vides.responsable_suivi.libelle).to be_nil
    expect(filtres_vides.statut).to be_nil
    expect(filtres_vides.illettrisme_potentiel?).to be false
  end

  it "lit la recherche" do
    expect(filtres(recherche: "ali").recherche).to eq "ali"
  end

  describe "suivi" do
    it "ne garde que les statuts choisis" do
      expect(filtres(statut_suivi_in: [ "", "a_renseigner" ]).statuts).to eq [ "a_renseigner" ]
    end

    it "propose les statuts filtrables avec leur libellé" do
      expect(filtres.options_statuts.first)
        .to eq [ I18n.t("statut_suivi.a_renseigner"), "a_renseigner" ]
    end
  end

  it "lit la période de début" do
    expect(filtres(debutee_le_gteq_datetime: "2025-01-01").debut.debut).to eq "2025-01-01"
  end

  it "lit l'onglet Illettrisme potentiel" do
    expect(filtres({}, "illettrisme_potentiel").illettrisme_potentiel?).to be true
    expect(filtres({}, "all").illettrisme_potentiel?).to be false
  end

  describe "campagne" do
    let(:campagne) { create :campagne }

    it "retrouve la campagne choisie" do
      choix = filtres(campagne_id_eq: campagne.id)

      expect(choix.campagne.enregistrement).to eq campagne
    end
  end

  describe "responsable de suivi" do
    let(:responsable) { create :compte_admin }

    it "retrouve le compte choisi" do
      choix = filtres(responsable_suivi_id_eq: responsable.id)

      expect(choix.responsable_suivi.enregistrement).to eq responsable
    end
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

  describe "statut" do
    it "lit le statut choisi" do
      expect(filtres(statut_eq: "1").statut).to eq "1"
    end

    it "propose les statuts avec leur libellé" do
      expect(filtres.options_statuts_evaluation.first)
        .to eq [ EvaluationEva.human_enum_name(:statut, "a_suivre"), 0 ]
    end

    it "n'est proposé qu'aux superadmins" do
      expect(filtres.filtre_statut?).to be false

      allow(compte).to receive(:superadmin?).and_return(true)
      expect(filtres.filtre_statut?).to be true
    end
  end
end
