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

    let(:value) { "12345678901234" }

    it "délègue le formatage à FormatageSiretHelper" do
      expect(FormatageSiretHelper).to receive(:formater_siret).with(value)
      options = component.instance_variable_get(:@input_component_options)
    end
  end
end
