require "rails_helper"

describe SuiviAccompagnementIllettrismeComponent, type: :component do
  let(:evaluation) { build(:evaluation, :eva, mise_en_action: mise_en_action) }
  let(:mise_en_action) { nil }
  let(:pas_encore_actif) { false }

  before do
    allow(MiseEnAction).to receive(:pas_encore_actif?).and_return(pas_encore_actif)
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

  context "quand l'option « Pas encore » est active" do
    let(:pas_encore_actif) { true }

    it "propose de répondre Oui, Pas encore ou Non, dans cet ordre" do
      expect(QuestionMiseEnActionComponent).to have_received(:new)
        .with(evaluation: evaluation,
              reponses: [ true, MiseEnAction::REPONSE_PAS_ENCORE, false ])
    end

    it "prépare aussi l'affichage de la réponse « Pas encore »" do
      expect(ReponseMiseEnActionComponent).to have_received(:new)
        .with(evaluation: evaluation, reponse: MiseEnAction::REPONSE_PAS_ENCORE)
    end
  end

  it "prépare le choix du type d'aide et de la raison" do
    expect(QualificationMiseEnActionComponent).to have_received(:new)
      .with(evaluation: evaluation, questionnaire: :remediation)
    expect(QualificationMiseEnActionComponent).to have_received(:new)
      .with(evaluation: evaluation, questionnaire: :difficulte)
  end
end
