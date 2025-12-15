require "rails_helper"

describe ImageFileInput, type: :input do
  let(:template) do
    view = ActionView::Base.new(
      ActionView::LookupContext.new([]),
      {},
      ActionController::Base.new
    )
    view.extend ActionView::Helpers::AssetTagHelper
    view.extend ActionView::Helpers::UrlHelper
    view.extend Rails.application.routes.url_helpers
    view
  end
  let(:object_name) { :question }
  let(:builder) { Formtastic::FormBuilder.new(object_name, object, template, {}) }
  let(:object) { Question.new }
  let(:method) { :illustration }
  let(:options) { {} }
  let(:input) { described_class.new(builder, template, object, object_name, method, options) }

  describe "#to_html" do
    subject(:html) { Capybara.string(input.to_html) }

    describe "attribut accept par défaut" do
      it "accepte toutes les images par défaut" do
        expect(html).to have_css("input[accept='image/*']")
      end

      context "quand un accept personnalisé est fourni dans input_html" do
        let(:options) { { input_html: { accept: "image/png,image/jpeg" } } }

        it "utilise l'accept personnalisé au lieu du défaut" do
          expect(html).to have_css("input[accept='image/png,image/jpeg']")
          expect(html).not_to have_css("input[accept='image/*']")
        end
      end
    end

    describe "hint par défaut" do
      context "quand aucun hint n'est fourni" do
        let(:options) { {} }

        it "affiche le hint par défaut avec les formats acceptés" do
          expect(html).to have_css("span.fr-hint-text",
                                   text: "Formats acceptés : .jpg, .png, .svg, .webp")
        end
      end

      context "quand un hint personnalisé est fourni" do
        let(:options) { { hint: "Indication personnalisée" } }

        it "utilise le hint personnalisé au lieu du défaut" do
          expect(html).to have_css("span.fr-hint-text", text: "Indication personnalisée")
        end
      end
    end

    describe "image de preview" do
      context "quand aucune image n'est attachée" do
        before do
          allow(object).to receive(:illustration).and_return(
            double(attached?: false)
          )
        end

        it "n'affiche pas d'image" do
          expect(html).not_to have_css("img.image-preview")
        end
      end

      context "quand une image est attachée" do
        let(:attachment) { double(attached?: true, filename: "test.jpg") }

        before do
          allow(object).to receive(:illustration).and_return(attachment)
          allow(attachment).to receive(:filename).and_return("test.jpg")
          # Mock de cdn_for qui est inclus via StorageHelper
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(described_class).to receive(:cdn_for)
            .with(attachment)
            .and_return("https://cdn.example.com/test.jpg")
          # rubocop:enable RSpec/AnyInstance
        end

        it "affiche l'image avec la classe image-preview" do
          expect(html).to have_css("img.image-preview")
        end
      end
    end
  end
end
