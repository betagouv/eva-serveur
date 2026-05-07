require "rails_helper"

describe SiretInputComponent, type: :component do
  describe "@input_component_options" do
    subject(:component) do
      described_class.new(
        id: "structure_siret",
        label: "SIRET",
        hint: "Format attendu : 123 456 789 01234",
        form: nil,
        method: :siret,
        value: value,
        required: true
      )
    end

    context "quand value est un siret brut" do
      let(:value) { "12345678901234" }

      it "utilise le formatage siret partagé" do
        options = component.instance_variable_get(:@input_component_options)
        expect(options[:value]).to eq("123 456 789 01234")
      end
    end

    context "quand value est un siret partiel" do
      let(:value) { "1234" }

      it "ne lève pas d'exception et conserve un format lisible" do
        expect { component }.not_to raise_error
        options = component.instance_variable_get(:@input_component_options)
        expect(options[:value]).to eq("123 4")
      end
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
