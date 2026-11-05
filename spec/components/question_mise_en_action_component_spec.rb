require "rails_helper"

describe QuestionMiseEnActionComponent, type: :component do
  let(:evaluation) { build(:evaluation, :eva, mise_en_action: mise_en_action) }
  let(:mise_en_action) { nil }
  let(:reponses) { [ true, false ] }
  let(:pas_encore_actif) { false }

  before do
    allow(MiseEnAction).to receive(:pas_encore_actif?).and_return(pas_encore_actif)
    render_inline(described_class.new(evaluation: evaluation, reponses: reponses))
  end

  it "pose la question de la mise en action" do
    bloc_question = page.find("[data-reponse='vide']")
    expect(bloc_question).to have_content(I18n.t("question_mise_en_action.question"))
    expect(bloc_question).to have_content(I18n.t("question_mise_en_action.description"))
    expect(bloc_question).to have_button(I18n.t("question_mise_en_action.bouton_oui"))
    expect(bloc_question).to have_button(I18n.t("question_mise_en_action.bouton_non"))
  end

  it "ne propose pas de répondre « Pas encore »" do
    expect(page).to have_no_button(
      I18n.t("question_mise_en_action.bouton_pas_encore")
    )
  end

  context "quand « Pas encore » fait partie des réponses" do
    let(:reponses) { [ true, false, MiseEnAction::REPONSE_PAS_ENCORE ] }

    it "propose de répondre « Pas encore »" do
      expect(page).to have_button(I18n.t("question_mise_en_action.bouton_pas_encore"))
    end
  end

  context "quand la mise en action est effectuée sans remédiation" do
    let(:mise_en_action) { build(:mise_en_action, effectuee: true) }

    it "masque la question pendant le choix du type d'aide" do
      expect(page).to have_css("[data-reponse='vide'].hidden", visible: :all)
    end
  end

  context "quand la mise en action n'est pas effectuée sans difficulté" do
    let(:mise_en_action) { build(:mise_en_action, effectuee: false) }

    it "masque la question pendant le choix de la raison" do
      expect(page).to have_css("[data-reponse='vide'].hidden", visible: :all)
    end
  end

  context "quand le pro a répondu Pas encore et que la date de revue n'est pas atteinte" do
    let(:mise_en_action) do
      build(:mise_en_action, effectuee: nil, date_revue: Date.current + 7,
                             choix_date_revue: "7_jours")
    end

    it "ne sélectionne ni Oui ni Non" do
      expect(page).to have_no_css(".reponse-mise-en-action.bouton--actif")
    end

    context "quand l'option « Pas encore » est active" do
      let(:pas_encore_actif) { true }

      it "masque la question" do
        expect(page).to have_css("[data-reponse='vide'].hidden", visible: :all)
      end
    end
  end
end
