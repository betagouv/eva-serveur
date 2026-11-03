require "rails_helper"

describe PrecisionAutreComponent, type: :component do
  let(:valeur) { nil }
  let(:erreur) { nil }

  before do
    render_inline(described_class.new(id: "precision-autre-1", questionnaire: questionnaire,
                                      valeur: valeur, erreur: erreur))
  end

  context "pour le type d'aide" do
    let(:questionnaire) { :remediation }

    it "affiche le champ « Précisez » avec son message d'information" do
      expect(page).to have_field(I18n.t("activerecord.attributes.mise_en_action.precision_autre"),
                                 type: "text")
      expect(page).to have_css("#precision-autre-1-messages .fr-message--info",
                               text: I18n.t("precision_autre.aide_remediation"))
    end

    it "limite la précision à 200 caractères" do
      expect(page).to have_css("input[name='precision_autre'][maxlength='200']")
    end

    it "fait lire le message d'erreur par les lecteurs d'écran" do
      expect(page).to have_css("input#precision-autre-1" \
                               "[aria-describedby='precision-autre-1-messages']")
      expect(page).to have_css("#precision-autre-1-messages[aria-live='polite']")
    end

    it "n'est pas en erreur" do
      expect(page).to have_no_css(".fr-input-group--error")
      expect(page).to have_no_css(".fr-message--error")
    end

    context "avec une précision enregistrée" do
      let(:valeur) { "aide sur mesure" }

      it "préremplit le champ" do
        expect(page.find("input").value).to eq "aide sur mesure"
      end
    end

    context "avec une erreur" do
      let(:erreur) { "Indiquez l’aide engagée en quelques mots." }

      it "remplace le message d'information par le message d'erreur" do
        expect(page).to have_css(".fr-input-group.fr-input-group--error")
        expect(page).to have_css("input.fr-input.fr-input--error")
        expect(page).to have_css("#precision-autre-1-messages .fr-message--error", text: erreur)
        expect(page).to have_no_css(".fr-message--info")
      end
    end
  end

  context "pour la raison" do
    let(:questionnaire) { :difficulte }

    it "affiche le message d'information de la raison" do
      expect(page).to have_css(".fr-message--info",
                               text: I18n.t("precision_autre.aide_difficulte"))
    end
  end
end
