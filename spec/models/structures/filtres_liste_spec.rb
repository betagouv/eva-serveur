require "rails_helper"

describe Structures::FiltresListe do
  let(:compte) { build :compte_conseiller }

  def filtres(parametres, options = {})
    described_class.new(ActionController::Parameters.new(parametres), compte,
                        activation: options[:activation])
  end

  it "se contente de paramètres absents" do
    filtres_vides = described_class.new(nil, compte, activation: nil)

    expect(filtres_vides.recherche).to be_nil
    expect(filtres_vides.type_structure).to be_nil
    expect(filtres_vides.creation.debut).to be_nil
  end

  it "lit la recherche, le type, l'usage et la région" do
    choix = filtres(recherche: "orleans", type_structure_eq: "mission_locale",
                    usage_eq: "Eva", region_eq: "Bretagne")

    expect(choix.recherche).to eq "orleans"
    expect(choix.type_structure).to eq "mission_locale"
    expect(choix.usage).to eq "Eva"
    expect(choix.region).to eq "Bretagne"
  end

  it "ne propose l'usage qu'aux comptes ANLCI" do
    expect(filtres({}).filtre_usage?).to be false

    allow(compte).to receive(:anlci?).and_return(true)
    expect(filtres({}).filtre_usage?).to be true
  end

  it "propose les régions des structures" do
    create :structure_locale, region: "Bretagne"

    expect(filtres({}).options_regions).to include("Bretagne")
  end

  describe "activation" do
    it "lit le statut choisi" do
      expect(filtres({}, activation: "actives").activation).to eq "actives"
    end

    it "propose chaque statut avec son libellé et son nombre de structures" do
      expect(filtres({}).options_activation("actives" => 3))
        .to include [ "#{I18n.t('active_admin.scopes.actives')} (3)", "actives" ]
    end
  end
end
