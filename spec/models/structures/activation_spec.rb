require "rails_helper"

describe Structures::Activation do
  let!(:sans_campagne) { create :structure_locale, :avec_admin }
  let!(:avec_campagne) { create :structure_locale, :avec_admin }

  before do
    create :campagne, compte: create(:compte_admin, structure: avec_campagne)
  end

  it "ne garde que les structures du statut choisi" do
    expect(described_class.filtre(StructureLocale.all, "sans_campagne"))
      .to contain_exactly(sans_campagne)
  end

  it "ignore un statut inconnu plutôt que de l'appeler sur la liste" do
    expect(described_class.filtre(StructureLocale.all, "destroy_all"))
      .to contain_exactly(sans_campagne, avec_campagne)
  end

  it "compte les structures de chaque statut, y compris dans une liste groupée" do
    liste = StructureLocale.avec_nombre_evaluations_et_date_derniere_evaluation

    nombres = described_class.nombres(liste)

    expect(nombres.keys).to eq described_class::STATUTS
    expect(nombres["sans_campagne"]).to eq 1
  end

  it "propose chaque statut avec son libellé et son nombre" do
    expect(described_class.options("actives" => 3))
      .to include [ "#{I18n.t('active_admin.scopes.actives')} (3)", "actives" ]
  end
end
