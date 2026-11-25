require "rails_helper"

describe Referentiels::FiltresListe do
  def filtres(parametres = {})
    described_class.new(ActionController::Parameters.new(parametres))
  end

  it "se contente de paramètres absents" do
    filtres_vides = described_class.new(nil)

    expect(filtres_vides.valeur(:libelle_i_cont)).to be_nil
    expect(filtres_vides.periode(:created_at).debut).to be_nil
  end

  it "lit la valeur d'un prédicat" do
    expect(filtres(financeur_eq: "true").valeur(:financeur_eq)).to eq "true"
  end

  it "lit une période" do
    expect(filtres(created_at_gteq_datetime: "2025-01-01").periode(:created_at).debut)
      .to eq "2025-01-01"
  end

  it "retrouve un enregistrement choisi" do
    question = create :question_saisie

    expect(filtres(questions_id_eq: question.id).choix(:questions_id_eq, Question).enregistrement)
      .to eq question
  end
end
