require "rails_helper"

describe SuiviAccompagnementIllettrismeComponent, type: :component do
  let(:evaluation) { build(:evaluation, :eva, mise_en_action: mise_en_action) }
  let(:mise_en_action) { nil }
  let(:je_ne_sais_pas_actif) { false }

  before do
    allow(MiseEnAction).to receive(:je_ne_sais_pas_actif?).and_return(je_ne_sais_pas_actif)
    allow(EnteteMiseEnActionComponent).to receive(:new).and_call_original
    allow(QuestionMiseEnActionComponent).to receive(:new).and_call_original
    allow(ReponseMiseEnActionComponent).to receive(:new).and_call_original
    allow(QualificationMiseEnActionComponent).to receive(:new).and_call_original
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

  it "prépare l'affichage des réponses Oui et Non" do
    expect(ReponseMiseEnActionComponent).to have_received(:new)
      .with(evaluation: evaluation, reponse: true)
    expect(ReponseMiseEnActionComponent).to have_received(:new)
      .with(evaluation: evaluation, reponse: false)
    expect(ReponseMiseEnActionComponent).to have_received(:new).twice
  end

  context "quand l'option « je ne sais pas » est active" do
    let(:je_ne_sais_pas_actif) { true }

    it "propose aussi de répondre « je ne sais pas »" do
      expect(QuestionMiseEnActionComponent).to have_received(:new)
        .with(evaluation: evaluation,
              reponses: [ true, false, MiseEnAction::REPONSE_JE_NE_SAIS_PAS ])
    end

    it "prépare aussi l'affichage de la réponse « je ne sais pas »" do
      expect(ReponseMiseEnActionComponent).to have_received(:new)
        .with(evaluation: evaluation, reponse: MiseEnAction::REPONSE_JE_NE_SAIS_PAS)
    end
  end

  it "prépare le choix du type d'aide et de la raison" do
    expect(QualificationMiseEnActionComponent).to have_received(:new)
      .with(evaluation: evaluation, questionnaire: :remediation)
    expect(QualificationMiseEnActionComponent).to have_received(:new)
      .with(evaluation: evaluation, questionnaire: :difficulte)
  end
end
