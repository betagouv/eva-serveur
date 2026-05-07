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

    context "quand value est présente" do
      let(:value) { "1234" }

      it "délègue le formatage à FormatageSiretHelper" do
        expect(FormatageSiretHelper).to receive(:formater_siret).with("1234").and_return("123 4")
        options = component.instance_variable_get(:@input_component_options)
        expect(options[:value]).to eq("123 4")
      end
    end

    context "quand value est vide" do
      let(:value) { nil }

      it "ne délègue pas le formatage" do
        expect(FormatageSiretHelper).not_to receive(:formater_siret)
        options = component.instance_variable_get(:@input_component_options)
        expect(options[:value]).to be_nil
      end
    end
  end
end
