require "rails_helper"

describe SuiviAccompagnementIllettrismeComponent, type: :component do
  let(:evaluation) { build(:evaluation, :eva, mise_en_action: mise_en_action) }
  let(:mise_en_action) { nil }
  let(:je_ne_sais_pas_actif) { false }

  before do
    allow(MiseEnAction).to receive(:je_ne_sais_pas_actif?).and_return(je_ne_sais_pas_actif)
    allow(EnteteMiseEnActionComponent).to receive(:new).and_call_original
    render_inline(described_class.new(evaluation: evaluation))
  end

  it "affiche le bandeau d'illettrisme potentiel" do
    expect(page).to have_css(".fr-notice.fr-notice--info .fr-notice__title",
                             text: I18n.t("suivi_accompagnement_illettrisme.bandeau"))
  end

  it "affiche l'en-tête de la mise en action" do
    expect(EnteteMiseEnActionComponent).to have_received(:new).with(evaluation: evaluation)
  end

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

  context "quand on ne sait pas si la mise en action est effectuée" do
    let(:mise_en_action) do
      build(:mise_en_action, effectuee: nil, motif: "action_prevue",
                             date_revue: Date.new(2026, 11, 5))
    end

    it "ne sélectionne ni Oui ni Non" do
      expect(page).to have_button("Oui")
      expect(page).to have_button("Non")
      expect(page).to have_no_css(".reponse-mise-en-action.bouton--actif")
    end

    it "n'affiche pas la réponse « je ne sais pas »" do
      expect(page).to have_no_content("Je ne sais pas")
    end

    context "quand l'option « je ne sais pas » est active" do
      let(:je_ne_sais_pas_actif) { true }

      it "affiche la réponse et la date de revue à la place des boutons" do
        expect(page).to have_css("[data-reponse='je_ne_sais_pas']", text: "Je ne sais pas")
        expect(page).to have_css(".tag", text: "Revue prévue le 05 nov. 2026")
        expect(page).to have_css("[data-reponse='vide'].hidden", visible: :all)
      end

      it "affiche le bandeau en attente" do
        expect(page).to have_css(".card__banner--illettrisme.card__banner--en-attente")
      end
    end
  end

  context "sans mise en action, quand l'option « je ne sais pas » est active" do
    let(:je_ne_sais_pas_actif) { true }

    it "propose de répondre « je ne sais pas »" do
      expect(page).to have_button("Je ne sais pas")
    end
  end

  context "sans mise en action, quand l'option « je ne sais pas » n'est pas active" do
    it "ne propose pas de répondre « je ne sais pas »" do
      expect(page).to have_no_button("Je ne sais pas")
    end
  end
end
