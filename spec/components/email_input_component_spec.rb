require "rails_helper"

describe EmailInputComponent, type: :component do
  describe "@input_component_options" do
    subject(:component) do
      described_class.new(
        id: "structure_email_contact",
        label: "Adresse électronique",
        hint: "Format attendu : nom@domaine.fr",
        form: nil,
        method: :email_contact,
        value: value,
        required: false
      )
    end

    let(:value) { "contact@structure.fr" }

    it "contient type email et autocomplete email dans input_html" do
      options = component.instance_variable_get(:@input_component_options)
      expect(options[:input_html][:type]).to eq("email")
      expect(options[:input_html][:autocomplete]).to eq("email")
      expect(options[:placeholder]).to be_nil
    end

    it "contient le hint et le label" do
      options = component.instance_variable_get(:@input_component_options)
      expect(options[:hint]).to eq("Format attendu : nom@domaine.fr")
      expect(options[:label]).to eq("Adresse électronique")
    end

    it "passe la valeur telle quelle" do
      options = component.instance_variable_get(:@input_component_options)
      expect(options[:value]).to eq("contact@structure.fr")
    end

    context "quand value est vide" do
      let(:value) { nil }

      it "passe une valeur vide" do
        options = component.instance_variable_get(:@input_component_options)
        expect(options[:value]).to be_nil
      end
    end
  end
end
