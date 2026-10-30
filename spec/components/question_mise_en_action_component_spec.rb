require "rails_helper"

describe QuestionMiseEnActionComponent, type: :component do
  let(:evaluation) { build(:evaluation, :eva, mise_en_action: mise_en_action) }
  let(:mise_en_action) { nil }
  let(:reponses) { [ true, false ] }
  let(:je_ne_sais_pas_actif) { false }

  before do
    allow(MiseEnAction).to receive(:je_ne_sais_pas_actif?).and_return(je_ne_sais_pas_actif)
    render_inline(described_class.new(evaluation: evaluation, reponses: reponses))
  end

  it "pose la question de la mise en action" do
    bloc_question = page.find("[data-reponse='vide']")
    expect(bloc_question).to have_content(I18n.t("question_mise_en_action.question"))
    expect(bloc_question).to have_content(I18n.t("question_mise_en_action.description"))
    expect(bloc_question).to have_button("Oui")
    expect(bloc_question).to have_button("Non")
  end

  it "ne propose pas de répondre « je ne sais pas »" do
    expect(page).to have_no_button("Je ne sais pas")
  end

  context "quand « je ne sais pas » fait partie des réponses" do
    let(:reponses) { [ true, false, MiseEnAction::REPONSE_JE_NE_SAIS_PAS ] }

    it "propose de répondre « je ne sais pas »" do
      expect(page).to have_button("Je ne sais pas")
    end
  end

  context "quand la mise en action est effectuée sans remédiation" do
    let(:mise_en_action) { build(:mise_en_action, effectuee: true) }

    it "sélectionne Oui" do
      expect(page).to have_css(".reponse-mise-en-action.bouton--actif", text: "Oui")
    end
  end

  context "quand on ne sait pas si la mise en action est effectuée" do
    let(:mise_en_action) do
      build(:mise_en_action, effectuee: nil, motif: "action_prevue",
                             date_revue: Date.new(2026, 11, 5))
    end

    it "ne sélectionne ni Oui ni Non" do
      expect(page).to have_no_css(".reponse-mise-en-action.bouton--actif")
    end

    context "quand l'option « je ne sais pas » est active" do
      let(:je_ne_sais_pas_actif) { true }

      it "masque la question" do
        expect(page).to have_css("[data-reponse='vide'].hidden", visible: :all)
      end
    end
  end
end
