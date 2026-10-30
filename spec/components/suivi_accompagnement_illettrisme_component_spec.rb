require "rails_helper"

describe SuiviAccompagnementIllettrismeComponent, type: :component do
  let(:evaluation) { build(:evaluation, :eva, mise_en_action: mise_en_action) }
  let(:mise_en_action) { nil }
  let(:je_ne_sais_pas_actif) { false }

  before do
    allow(MiseEnAction).to receive(:je_ne_sais_pas_actif?).and_return(je_ne_sais_pas_actif)
    allow(EnteteMiseEnActionComponent).to receive(:new).and_call_original
    allow(QuestionMiseEnActionComponent).to receive(:new).and_call_original
    render_inline(described_class.new(evaluation: evaluation))
  end

  it "affiche le bandeau d'illettrisme potentiel" do
    expect(page).to have_css(".fr-notice.fr-notice--info .fr-notice__title",
                             text: I18n.t("suivi_accompagnement_illettrisme.bandeau"))
  end

  it "affiche l'en-tête de la mise en action" do
    expect(EnteteMiseEnActionComponent).to have_received(:new).with(evaluation: evaluation)
  end

  it "pose la question de la mise en action avec Oui et Non" do
    expect(QuestionMiseEnActionComponent).to have_received(:new)
      .with(evaluation: evaluation, reponses: [ true, false ])
  end

  context "quand l'option « je ne sais pas » est active" do
    let(:je_ne_sais_pas_actif) { true }

    it "propose aussi de répondre « je ne sais pas »" do
      expect(QuestionMiseEnActionComponent).to have_received(:new)
        .with(evaluation: evaluation,
              reponses: [ true, false, MiseEnAction::REPONSE_JE_NE_SAIS_PAS ])
    end
  end

  it "affiche les pistes de solutions" do
    expect(page).to have_link(href: /rechercher-une-solution-de-remediation/)
  end

  context "sans mise en action" do
    it "masque les deux questionnaires" do
      expect(page).to have_css(".questions-remediation.hidden", visible: :all)
      expect(page).to have_css(".questions-difficulte.hidden", visible: :all)
    end
  end

  context "quand la mise en action est effectuée sans remédiation" do
    let(:mise_en_action) { build(:mise_en_action, effectuee: true) }

    it "affiche le questionnaire de remédiation" do
      expect(page).to have_css(".questions-remediation:not(.hidden)")
      expect(page).to have_css(".questions-difficulte.hidden", visible: :all)
    end
  end

  context "quand la mise en action n'est pas effectuée sans difficulté" do
    let(:mise_en_action) { build(:mise_en_action, effectuee: false) }

    it "affiche le questionnaire de difficulté" do
      expect(page).to have_css(".questions-difficulte:not(.hidden)")
      expect(page).to have_css(".questions-remediation.hidden", visible: :all)
    end
  end

  context "quand on ne sait pas si la mise en action est effectuée" do
    let(:mise_en_action) do
      build(:mise_en_action, effectuee: nil, motif: "action_prevue",
                             date_revue: Date.new(2026, 11, 5))
    end

    it "n'affiche pas la réponse « je ne sais pas »" do
      expect(page).to have_no_content("Je ne sais pas")
    end

    context "quand l'option « je ne sais pas » est active" do
      let(:je_ne_sais_pas_actif) { true }

      it "affiche la réponse et la date de revue" do
        expect(page).to have_css("[data-reponse='je_ne_sais_pas']", text: "Je ne sais pas")
        expect(page).to have_css(".tag", text: "Revue prévue le 05 nov. 2026")
      end
    end
  end
end
