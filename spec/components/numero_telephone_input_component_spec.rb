require "rails_helper"

describe NumeroTelephoneInputComponent, type: :component do
  describe "@input_component_options" do
    subject(:component) do
      described_class.new(
        id: "structure_telephone",
        label: "Numéro de téléphone",
        hint: "Format attendu : (+33) 1 22 33 44 55",
        form: nil,
        method: :telephone,
        value: value,
        required: false
      )
    end

    let(:value) { "0122334455" }

    it "contient data-numero-telephone-input et type tel dans input_html" do
      options = component.instance_variable_get(:@input_component_options)
      expect(options[:input_html]["data-numero-telephone-input"]).to eq("true")
      expect(options[:input_html][:type]).to eq("tel")
      expect(options[:input_html][:autocomplete]).to eq("tel")
    end

    it "contient le hint et le label" do
      options = component.instance_variable_get(:@input_component_options)
      expect(options[:hint]).to eq("Format attendu : (+33) 1 22 33 44 55")
      expect(options[:label]).to eq("Numéro de téléphone")
    end

    context "quand value est 0122334455" do
      let(:value) { "0122334455" }

      it "formate en (+33) 1 22 33 44 55" do
        options = component.instance_variable_get(:@input_component_options)
        expect(options[:value]).to eq("(+33) 1 22 33 44 55")
      end
    end

    context "quand value est +33122334455" do
      let(:value) { "+33122334455" }

      it "formate en (+33) 1 22 33 44 55" do
        options = component.instance_variable_get(:@input_component_options)
        expect(options[:value]).to eq("(+33) 1 22 33 44 55")
      end
    end

    context "quand value est (+33)122334455" do
      let(:value) { "(+33)122334455" }

      it "formate en (+33) 1 22 33 44 55" do
        options = component.instance_variable_get(:@input_component_options)
        expect(options[:value]).to eq("(+33) 1 22 33 44 55")
      end
    end

    context "quand value est vide" do
      let(:value) { nil }

      it "passe une valeur vide" do
        options = component.instance_variable_get(:@input_component_options)
        expect(options[:value]).to be_nil
      end
    end

    context "quand value est 064700365 (9 chiffres commençant par 0, saisie incomplète)" do
      let(:value) { "064700365" }

      it "ne formate pas pour permettre d’ajouter le 10ᵉ chiffre" do
        options = component.instance_variable_get(:@input_component_options)
        expect(options[:value]).to eq("064700365")
      end
    end
  end
end
