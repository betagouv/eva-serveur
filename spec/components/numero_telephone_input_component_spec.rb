require "rails_helper"

describe NumeroTelephoneInputComponent, type: :component do
  describe "@input_component_options" do
    subject(:component) do
      described_class.new(
        id: "structure_telephone",
        label: "Numéro de téléphone",
        form: nil,
        value: value
      )
    end

    let(:value) { "0122334455" }

    it "contient type tel dans input_html" do
      options = component.instance_variable_get(:@input_component_options)
      expect(options[:type]).to eq("tel")
      expect(options[:input_html][:autocomplete]).to eq("tel")
    end

    it "contient le hint et le label" do
      options = component.instance_variable_get(:@input_component_options)
      expect(options[:hint]).to eq("Format attendu : (+33) 1 22 33 44 55")
      expect(options[:label]).to eq("Numéro de téléphone")
    end

    context "quand value est vide" do
      let(:value) { nil }

      it "passe une valeur vide" do
        options = component.instance_variable_get(:@input_component_options)
        expect(options[:value]).to be_nil
      end
    end

    context "quand une valeur est passée" do
      let(:value) { "01 23 45 67 89" }

      it "affiche la valeur" do
        options = component.instance_variable_get(:@input_component_options)
        expect(options[:value]).to eq("01 23 45 67 89")
      end
    end
  end
end
