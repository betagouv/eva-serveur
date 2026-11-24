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

  it "signale l'illettrisme potentiel par un bandeau d'information" do
    expect(page).to have_css(".fr-notice.fr-notice--info .fr-notice__title",
                             text: I18n.t("suivi_accompagnement_illettrisme.badge"))
  end

  it "affiche l'en-tête de la mise en action" do
    expect(EnteteMiseEnActionComponent).to have_received(:new)
      .with(evaluation: evaluation, lien_evaluation: false, compact: false)
  end

  context "sur le tableau de bord" do
    let(:evaluation) { create(:evaluation, :eva, mise_en_action: mise_en_action) }

    before do
      render_inline(described_class.new(evaluation: evaluation, contexte: :tableau_de_bord))
    end

    it "affiche l'en-tête compact avec le lien vers l'évaluation" do
      expect(EnteteMiseEnActionComponent).to have_received(:new)
        .with(evaluation: evaluation, lien_evaluation: true, compact: true)
    end

    it "demande au JS de passer à la personne suivante après la réponse" do
      expect(page).to have_css(".suivi-accompagnement-illettrisme[data-personne-suivante]",
                               visible: :all)
    end
  end

  context "sur la fiche bénéficiaire" do
    let(:evaluation) { create(:evaluation, :eva, mise_en_action: mise_en_action) }

    before do
      render_inline(described_class.new(evaluation: evaluation, contexte: :fiche_beneficiaire))
    end

    it "garde l'en-tête large et renvoie vers l'évaluation" do
      expect(EnteteMiseEnActionComponent).to have_received(:new)
        .with(evaluation: evaluation, lien_evaluation: true, compact: false)
    end

    it "ne passe pas à la personne suivante : la carte porte sur cette personne" do
      expect(page).to have_no_css(".suivi-accompagnement-illettrisme[data-personne-suivante]",
                                  visible: :all)
    end
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

  it "ne propose pas de passer à une autre personne sans adresse de la suivante" do
    expect(page).to have_no_link(I18n.t("suivi_accompagnement_illettrisme.passer"))
  end

  context "quand le tableau de bord donne l'adresse de la personne suivante" do
    let(:evaluation) { create(:evaluation, :eva, mise_en_action: mise_en_action) }

    before do
      render_inline(described_class.new(evaluation: evaluation, contexte: :tableau_de_bord,
                                        url_personne_suivante: "/admin/dashboard?apres=1"))
    end

    it "propose de passer à une autre personne" do
      expect(page).to have_link(I18n.t("suivi_accompagnement_illettrisme.passer"),
                                href: "/admin/dashboard?apres=1",
                                class: %w[fr-link fr-icon-arrow-right-line fr-link--icon-right])
    end
  end
end
