require "rails_helper"

describe EmailInput, type: :input do
  let(:template) do
    ActionView::Base.new(
      ActionView::LookupContext.new([]),
      {},
      ActionController::Base.new
    )
  end
  let(:object_name) { :structure_locale }
  let(:builder) { Formtastic::FormBuilder.new(object_name, object, template, {}) }
  let(:object) { StructureLocale.new }
  let(:method) { :email_contact }
  let(:options) { {} }
  let(:input) { described_class.new(builder, template, object, object_name, method, options) }

  describe "#to_html" do
    subject(:html) { Capybara.string(input.to_html) }

    context "quand il y a une erreur" do
      before do
        object.errors.add(method, :invalid)
      end

      it "affiche un seul message d'erreur inline" do
        expect(html).to have_css("p.inline-errors", text: I18n.t("errors.messages.invalid"),
count: 1)
      end
    end
  end
end
