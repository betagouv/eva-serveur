require "rails_helper"

describe EnteteMiseEnActionComponent, type: :component do
  let(:beneficiaire) { build(:beneficiaire, nom: "Jean Dupont") }
  let(:campagne) { build(:campagne) }
  let(:evaluation) do
    build(:evaluation, :eva, beneficiaire: beneficiaire, campagne: campagne,
                             debutee_le: Time.zone.local(2026, 4, 28, 10))
  end

  before do
    allow(ResultatComponent).to receive(:new).and_call_original
    render_inline(described_class.new(evaluation: evaluation))
  end

  it "affiche le nom du bénéficiaire" do
    expect(page).to have_css(".nom-anonymisable", text: "Jean Dupont")
  end

  it "affiche la date de l'évaluation" do
    expect(page).to have_content(I18n.t("entete_mise_en_action.evaluation_du",
                                        date: "28/04/2026"))
  end

  context "quand le bénéficiaire est anonymisé" do
    let(:beneficiaire) { build(:beneficiaire, nom: "Jean Dupont", anonymise_le: Time.current) }

    it "affiche l'icône anonyme" do
      expect(page).to have_css(".nom-anonymisable svg")
    end
  end

  context "avec une campagne de positionnement en littératie et numératie" do
    let(:campagne) do
      build(:campagne, situations_configurations: [
              build(:situation_configuration, :litteratie),
              build(:situation_configuration, :numeratie)
            ])
    end
    let(:evaluation) do
      build(:evaluation, :eva, beneficiaire: beneficiaire, campagne: campagne,
                               positionnement_niveau_litteratie: "profil2",
                               positionnement_niveau_numeratie: "profil3")
    end

    it "affiche les résultats de littératie et de numératie" do
      expect(ResultatComponent).to have_received(:new).with(domaine: :litteratie, niveau: "profil2")
      expect(ResultatComponent).to have_received(:new).with(domaine: :numeratie, niveau: "profil3")
      expect(ResultatComponent).to have_received(:new).twice
    end
  end

  context "avec une campagne de diagnostic" do
    let(:campagne) do
      build(:campagne, situations_configurations: [
              build(:situation_configuration, situation: build(:situation_maintenance))
            ])
    end
    let(:evaluation) do
      build(:evaluation, :eva, beneficiaire: beneficiaire, campagne: campagne,
                               niveau_cefr: "pre_A1", niveau_cnef: "X1")
    end

    it "affiche les résultats de français et de mathématiques" do
      expect(ResultatComponent).to have_received(:new).with(domaine: :francais, niveau: "pre_A1")
      expect(ResultatComponent).to have_received(:new).with(domaine: :mathematiques, niveau: "X1")
      expect(ResultatComponent).to have_received(:new).twice
    end
  end
end
