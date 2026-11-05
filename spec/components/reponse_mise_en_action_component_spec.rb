require "rails_helper"

describe ReponseMiseEnActionComponent, type: :component do
  let(:evaluation) { build(:evaluation, :eva, mise_en_action: mise_en_action) }
  let(:mise_en_action) { nil }
  let(:pas_encore_actif) { false }

  before do
    allow(MiseEnAction).to receive(:pas_encore_actif?).and_return(pas_encore_actif)
    render_inline(described_class.new(evaluation: evaluation, reponse: reponse))
  end

  context "pour la réponse Oui" do
    let(:reponse) { true }

    context "quand la mise en action est effectuée avec remédiation" do
      let(:mise_en_action) do
        build(:mise_en_action, effectuee: true, remediation: "formation_metier",
                               repondue_le: Time.zone.local(2026, 10, 27, 14))
      end

      it "ne propose pas de trouver une solution" do
        expect(page).to have_no_link(I18n.t("reponse_mise_en_action.trouver_solution"))
      end

      it "affiche la date de réponse" do
        expect(page).to have_css(".mise-en-action-repondue__date",
                                 text: I18n.t("reponse_mise_en_action.repondue_le",
                                              date: "27/10/2026"))
      end

      it "affiche la réponse et l'aide choisie" do
        bloc_reponse = page.find("[data-reponse='true'].mise-en-action:not(.hidden)")
        expect(bloc_reponse).to have_content(I18n.t("reponse_mise_en_action.titre_true"))
        expect(bloc_reponse).to have_css(
          ".tag",
          text: I18n.t("activerecord.attributes.mise_en_action.remediation.formation_metier")
        )
        expect(bloc_reponse).to have_link(I18n.t("reponse_mise_en_action.modifier"),
                                          class: "modifier-mise-en-action")
      end
    end

    context "quand la remédiation est indéterminée" do
      let(:mise_en_action) { build(:mise_en_action, effectuee: true, remediation: MiseEnAction::QUALIFICATION_INDETERMINEE) }

      it "masque la réponse : le type d'aide reste à qualifier" do
        expect(page).to have_css("[data-reponse='true'].mise-en-action.hidden", visible: :all)
      end
    end

    context "quand la mise en action est effectuée sans remédiation" do
      let(:mise_en_action) { build(:mise_en_action, effectuee: true) }

      it "masque la réponse" do
        expect(page).to have_css("[data-reponse='true'].mise-en-action.hidden", visible: :all)
      end
    end

    context "sans mise en action" do
      it "masque la réponse" do
        expect(page).to have_css("[data-reponse='true'].mise-en-action.hidden", visible: :all)
      end

      it "prépare une date de réponse vide et masquée, que le JS remplira" do
        expect(page).to have_css(".mise-en-action-repondue__date.hidden", text: "", visible: :all)
      end
    end
  end

  context "pour la réponse Non" do
    let(:reponse) { false }

    context "quand la mise en action n'est pas effectuée avec difficulté" do
      let(:mise_en_action) do
        build(:mise_en_action, effectuee: false, difficulte: "freins_peripheriques")
      end

      it "propose de trouver une solution près de chez la personne" do
        expect(page).to have_link(I18n.t("reponse_mise_en_action.trouver_solution"),
                                  href: /rechercher-une-solution-de-remediation/,
                                  target: "_blank")
      end

      it "affiche la réponse et la raison choisie" do
        bloc_reponse = page.find("[data-reponse='false'].mise-en-action:not(.hidden)")
        expect(bloc_reponse).to have_content(I18n.t("reponse_mise_en_action.titre_false"))
        expect(bloc_reponse).to have_css(
          ".tag",
          text: I18n.t("activerecord.attributes.mise_en_action.difficulte.freins_peripheriques")
        )
      end
    end

    context "quand la mise en action est effectuée avec remédiation" do
      let(:mise_en_action) do
        build(:mise_en_action, effectuee: true, remediation: "formation_metier")
      end

      it "masque la réponse" do
        expect(page).to have_css("[data-reponse='false'].mise-en-action.hidden", visible: :all)
      end
    end
  end

  context "pour la réponse Pas encore, avec une date de revue choisie" do
    let(:reponse) { MiseEnAction::REPONSE_PAS_ENCORE }
    let(:pas_encore_actif) { true }
    let(:mise_en_action) do
      build(:mise_en_action, effectuee: nil, date_revue: Date.new(2026, 11, 18),
                             choix_date_revue: "14_jours")
    end

    it "affiche la réponse et la relance prévue" do
      bloc_reponse = page.find("[data-reponse='pas_encore'].mise-en-action:not(.hidden)")
      expect(bloc_reponse).to have_content(I18n.t("reponse_mise_en_action.titre_pas_encore"))
      expect(bloc_reponse).to have_css(
        ".tag",
        text: I18n.t("reponse_mise_en_action.relance_prevue", date: "18/11/2026")
      )
    end
  end
end
