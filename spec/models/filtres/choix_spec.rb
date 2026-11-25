require "rails_helper"

describe Filtres::Choix do
  let(:campagne) { create :campagne, libelle: "Paris 2025" }

  def choix(parametres)
    described_class.new(ActionController::Parameters.new(parametres), :campagne_id_eq, Campagne)
  end

  it "retrouve l'enregistrement choisi et son libellé" do
    choisi = choix(campagne_id_eq: campagne.id)

    expect(choisi.id).to eq campagne.id
    expect(choisi.enregistrement).to eq campagne
    expect(choisi.libelle).to eq campagne.display_name
  end

  it "ne cherche rien sans choix" do
    expect(Campagne).not_to receive(:find_by)

    expect(choix(campagne_id_eq: "").libelle).to be_nil
  end

  it "ignore un identifiant inconnu" do
    expect(choix(campagne_id_eq: SecureRandom.uuid).libelle).to be_nil
  end
end
