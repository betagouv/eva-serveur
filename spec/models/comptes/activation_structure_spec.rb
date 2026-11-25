require "rails_helper"

describe Comptes::ActivationStructure do
  let(:structure_sans_campagne) { create :structure_locale, :avec_admin }
  let(:structure_avec_campagne) { create :structure_locale, :avec_admin }
  let!(:compte_sans_campagne) { create :compte_conseiller, structure: structure_sans_campagne }
  let!(:compte_avec_campagne) { create :compte_conseiller, structure: structure_avec_campagne }

  before { create :campagne, compte: compte_avec_campagne }

  it "ne garde que les comptes dont la structure a le statut d'activation choisi" do
    comptes = described_class.filtre(Compte.all, "sans_campagne")

    expect(comptes).to include(compte_sans_campagne)
    expect(comptes).not_to include(compte_avec_campagne)
  end

  it "ignore un statut inconnu plutôt que de l'appeler sur Structure" do
    expect(described_class.filtre(Compte.all, "destroy_all")).to include(compte_sans_campagne,
                                                                         compte_avec_campagne)
  end

  it "compte les comptes pour chaque statut" do
    nombres = described_class.nombres(Compte.where(id: [ compte_sans_campagne.id,
                                                         compte_avec_campagne.id ]))

    expect(nombres.keys).to eq described_class::STATUTS
    expect(nombres["sans_campagne"]).to eq 1
  end
end
