require "rails_helper"

describe SiretInput, type: :input do
  let(:template) do
    ActionView::Base.new(
      ActionView::LookupContext.new([]),
      {},
      ActionController::Base.new
    )
  end
  let(:object_name) { :structure_locale }
  let(:builder) { Formtastic::FormBuilder.new(object_name, object, template, {}) }
  let(:value) { "1234" }
  let(:object) { StructureLocale.new(siret: value) }
  let(:method) { :siret }
  let(:options) { {} }

  describe "#formatted_siret_value" do
    it "délègue à FormatageSiretHelper" do
      input = described_class.new(builder, template, object, object_name, method, options)
      expect(FormatageSiretHelper).to receive(:formater_siret).with(value)
      input.send(:formatted_siret_value)
    end

    it "renvoie nil si l'objet n'a pas de siret" do
      input = described_class.new(builder, template, Compte.new, object_name, method, options)
      expect(input.send(:formatted_siret_value)).to be_nil
    end
  end
end
