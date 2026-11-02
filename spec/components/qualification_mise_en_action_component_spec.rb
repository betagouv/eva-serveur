require "rails_helper"

describe QualificationMiseEnActionComponent, type: :component do
  let(:evaluation) { build(:evaluation, :eva, mise_en_action: mise_en_action) }
  let(:mise_en_action) { nil }

  before do
    render_inline(described_class.new(evaluation: evaluation, questionnaire: questionnaire))
  end

  context "pour le type d'aide" do
    let(:questionnaire) { :remediation }

    it "se branche sur le JS de la mise en action" do
      expect(page).to have_css(".qcm.questions-remediation", visible: :all)
    end

    it "rappelle la réponse et propose de la changer" do
      bloc = page.find(".qcm", visible: :all)
      expect(bloc).to have_text(:all, I18n.t("qualification_mise_en_action.titre_remediation"))
      expect(bloc).to have_link(I18n.t("qualification_mise_en_action.changer"),
                                class: "changer-reponse-mise-en-action", visible: :all)
    end

    it "demande de quelle aide il s'agit" do
      bloc = page.find(".qcm", visible: :all)
      expect(bloc).to have_text(:all, I18n.t("qualification_mise_en_action.question_remediation"))
      expect(bloc).to have_text(:all, I18n.t("qualification_mise_en_action.description"))
    end

    it "propose un tag cliquable par type d'aide, sans « indéterminé »" do
      tags = page.all(".qualification-mise-en-action__choix button.fr-tag", visible: :all)
      expect(tags.map { |tag| tag["data-qualification"] })
        .to eq(MiseEnAction::REMEDIATIONS - [ MiseEnAction::QUALIFICATION_INDETERMINEE ])
      expect(page).to have_button(
        I18n.t("activerecord.attributes.mise_en_action.remediation.formation_metier"),
        visible: :all
      )
    end

    it "n'a pas de bouton Valider ni Ignorer" do
      expect(page).to have_no_css(".valide-qcm, .bouton-fermer", visible: :all)
    end

    it "est masqué sans mise en action" do
      expect(page).to have_css(".qcm.hidden", visible: :all)
    end

    context "quand la mise en action est effectuée sans remédiation" do
      let(:mise_en_action) { build(:mise_en_action, effectuee: true) }

      it "est affiché" do
        expect(page).to have_css(".qcm.questions-remediation:not(.hidden)")
      end
    end

    context "quand la mise en action est effectuée avec remédiation" do
      let(:mise_en_action) do
        build(:mise_en_action, effectuee: true, remediation: "formation_metier")
      end

      it "est masqué" do
        expect(page).to have_css(".qcm.hidden", visible: :all)
      end
    end
  end

  context "pour la raison" do
    let(:questionnaire) { :difficulte }

    it "demande pourquoi aucune aide n'est prévue" do
      bloc = page.find(".qcm.questions-difficulte", visible: :all)
      expect(bloc).to have_text(:all, I18n.t("qualification_mise_en_action.titre_difficulte"))
      expect(bloc).to have_text(:all, I18n.t("qualification_mise_en_action.question_difficulte"))
    end

    context "quand la mise en action n'est pas effectuée sans difficulté" do
      let(:mise_en_action) { build(:mise_en_action, effectuee: false) }

      it "est affiché" do
        expect(page).to have_css(".qcm.questions-difficulte:not(.hidden)")
      end
    end
  end
end
