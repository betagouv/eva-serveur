require "rails_helper"

describe BaseInputComponent, type: :component do
  subject(:composant) do
    described_class.new(id: "compte_email", label: "Email", form: form, method: :email)
  end

  let(:compte) { Compte.new }
  let(:form) do
    ActionView::Helpers::FormBuilder.new(:compte, compte, vc_test_controller.view_context, {})
  end

  context "quand le champ est en erreur" do
    before { compte.errors.add(:email, "n'est pas valide") }

    it "détecte l'erreur" do
      expect(composant.has_errors?).to be true
    end

    it "génère le message d'erreur DSFR" do
      expect(composant.error_html)
        .to eq('<p class="fr-message fr-message--error">n\'est pas valide</p>')
    end

    it "marque l'input en erreur" do
      expect(composant.input_classes).to eq("fr-input fr-input--error")
    end

    it "conserve les classes spécifiques avant fr-input" do
      expect(composant.input_classes("fr-password__input"))
        .to eq("fr-password__input fr-input fr-input--error")
    end

    it "marque le label en erreur" do
      expect(composant.label_classes).to eq("fr-label fr-label--error")
    end
  end

  context "quand le champ n'est pas en erreur" do
    it "ne détecte pas d'erreur" do
      expect(composant.has_errors?).to be false
      expect(composant.error_html).to eq("")
    end

    it "ne marque pas l'input en erreur" do
      expect(composant.input_classes).to eq("fr-input")
    end

    it "ne marque pas le label en erreur" do
      expect(composant.label_classes).to eq("fr-label")
    end
  end
end
