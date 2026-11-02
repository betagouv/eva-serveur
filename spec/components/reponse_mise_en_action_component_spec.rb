require "rails_helper"

describe ReponseMiseEnActionComponent, type: :component do
  let(:evaluation) { build(:evaluation, :eva, mise_en_action: mise_en_action) }
  let(:mise_en_action) { nil }
  let(:je_ne_sais_pas_actif) { false }

  before do
    allow(MiseEnAction).to receive(:je_ne_sais_pas_actif?).and_return(je_ne_sais_pas_actif)
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

      it "affiche la réponse sans aide choisie" do
        expect(page).to have_css("[data-reponse='true'].mise-en-action:not(.hidden)")
        expect(page).to have_css(".tag.hidden", visible: :all)
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

  context "pour la réponse « je ne sais pas »" do
    let(:reponse) { MiseEnAction::REPONSE_JE_NE_SAIS_PAS }
    let(:je_ne_sais_pas_actif) { true }
    let(:mise_en_action) do
      build(:mise_en_action, effectuee: nil, motif: "action_prevue",
                             date_revue: Date.new(2026, 11, 5))
    end

    it "affiche la réponse et la date de revue" do
      bloc_reponse = page.find("[data-reponse='je_ne_sais_pas'].mise-en-action:not(.hidden)")
      expect(bloc_reponse).to have_content(I18n.t("reponse_mise_en_action.titre_je_ne_sais_pas"))
      expect(bloc_reponse).to have_css(
        ".tag",
        text: I18n.t("reponse_mise_en_action.revue_prevue", date: "05 nov. 2026")
      )
    end
  end
end
