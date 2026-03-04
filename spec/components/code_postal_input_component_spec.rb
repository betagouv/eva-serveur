require "rails_helper"

describe CodePostalInputComponent, type: :component do
  describe "@input_component_options" do
    subject(:component) do
      described_class.new(
        id: "structure_code_postal",
        label: "Code postal",
        hint: "Format attendu : 5 chiffres",
        form: nil,
        method: :code_postal,
        value: value,
        required: true
      )
    end

    let(:value) { "75001" }

    it "contient maxlength 5 et data-code-postal-input dans input_html" do
      options = component.instance_variable_get(:@input_component_options)
      expect(options[:input_html]["data-code-postal-input"]).to eq("true")
      expect(options[:input_html][:maxlength]).to eq(5)
      expect(options[:input_html][:inputmode]).to eq("numeric")
      expect(options[:input_html][:pattern]).to eq("[0-9]*")
    end

    it "contient le hint et le label" do
      options = component.instance_variable_get(:@input_component_options)
      expect(options[:hint]).to eq("Format attendu : 5 chiffres")
      expect(options[:label]).to eq("Code postal")
    end

    context "quand value est TYPE_NON_COMMUNIQUE" do
      let(:value) { StructureLocale::TYPE_NON_COMMUNIQUE }

      it "passe une valeur vide pour ne pas afficher non_communique" do
        options = component.instance_variable_get(:@input_component_options)
        expect(options[:value]).to be_nil
      end
    end

    context "quand value est un code à 5 chiffres" do
      let(:value) { "69003" }

      it "conserve la valeur normalisée" do
        options = component.instance_variable_get(:@input_component_options)
        expect(options[:value]).to eq("69003")
      end
    end

    context "quand value contient des caractères non numériques" do
      let(:value) { "75 001" }

      it "ne garde que les 5 premiers chiffres" do
        options = component.instance_variable_get(:@input_component_options)
        expect(options[:value]).to eq("75001")
      end
    end
  end
end
