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
  let(:object) { StructureLocale.new(siret: value) }
  let(:method) { :siret }
  let(:options) { {} }
  let(:input) { described_class.new(builder, template, object, object_name, method, options) }

  describe "#formatted_siret_value" do
    subject(:formatted_siret_value) { input.send(:formatted_siret_value) }

    context "quand le siret est brut" do
      let(:value) { "12345678901234" }

      it "utilise le formatage partagé" do
        expect(formatted_siret_value).to eq("123 456 789 01234")
      end
    end

    context "quand le siret est partiel" do
      let(:value) { "1234" }

      it "ne lève pas d'exception" do
        expect { formatted_siret_value }.not_to raise_error
        expect(formatted_siret_value).to eq("123 4")
      end
    end

    context "quand le siret est vide" do
      let(:value) { nil }

      it "retourne nil" do
        expect(formatted_siret_value).to be_nil
      end
    end
  end
end
