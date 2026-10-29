require "rails_helper"

describe SuiviAccompagnementIllettrismeComponent, type: :component do
  let(:evaluation) { build(:evaluation, :eva, mise_en_action: mise_en_action) }
  let(:mise_en_action) { nil }

  before { render_inline(described_class.new(evaluation: evaluation)) }

  it "affiche le titre" do
    expect(page).to have_css("h3", text: "Cette personne semble avoir besoin de " \
                                         "consolider ses compétences de base.")
  end

  it "affiche les pistes de solutions" do
    expect(page).to have_link(href: /rechercher-une-solution-de-remediation/)
  end

  context "sans mise en action" do
    it "affiche le bandeau en attente" do
      expect(page).to have_css(".card__banner--illettrisme.card__banner--en-attente")
    end

    it "masque les deux questionnaires" do
      expect(page).to have_css(".questions-remediation.hidden", visible: :all)
      expect(page).to have_css(".questions-difficulte.hidden", visible: :all)
    end
  end

  context "quand la mise en action est effectuée sans remédiation" do
    let(:mise_en_action) { build(:mise_en_action, effectuee: true) }

    it "affiche le bandeau en attente" do
      expect(page).to have_css(".card__banner--en-attente")
    end

    it "affiche le questionnaire de remédiation" do
      expect(page).to have_css(".questions-remediation:not(.hidden)")
      expect(page).to have_css(".questions-difficulte.hidden", visible: :all)
    end
  end

  context "quand la mise en action est effectuée avec remédiation" do
    let(:mise_en_action) do
      build(:mise_en_action, effectuee: true, remediation: "formation_metier")
    end

    it "affiche le bandeau en succès" do
      expect(page).to have_css(".card__banner--succes")
    end
  end

  context "quand la mise en action n'est pas effectuée sans difficulté" do
    let(:mise_en_action) { build(:mise_en_action, effectuee: false) }

    it "affiche le questionnaire de difficulté" do
      expect(page).to have_css(".questions-difficulte:not(.hidden)")
      expect(page).to have_css(".questions-remediation.hidden", visible: :all)
    end
  end
end
