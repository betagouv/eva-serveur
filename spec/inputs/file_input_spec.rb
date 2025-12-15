require "rails_helper"

describe FileInput, type: :input do
  let(:template) do
    ActionView::Base.new(
      ActionView::LookupContext.new([]),
      {},
      ActionController::Base.new
    )
  end
  let(:object_name) { :transcription }
  let(:builder) { Formtastic::FormBuilder.new(object_name, object, template, {}) }
  let(:object) { Transcription.new }
  let(:method) { :audio }
  let(:options) { {} }
  let(:input) { described_class.new(builder, template, object, object_name, method, options) }

  describe "#to_html" do
    subject(:html) { Capybara.string(input.to_html) }

    it "génère un conteneur avec la classe fr-upload-group" do
      expect(html).to have_css("li.fr-upload-group")
    end

    it "génère un label avec la classe fr-label" do
      expect(html).to have_css("label.fr-label")
    end

    it "génère un input avec la classe fr-upload" do
      expect(html).to have_css("input.fr-upload[type='file']")
    end

    it "génère un conteneur de messages avec la classe fr-messages-group" do
      expect(html).to have_css("div.fr-messages-group")
    end

    it "génère un label avec l'attribut for pointant vers l'input" do
      expect(html).to have_css("label.fr-label[for='transcription_audio']")
    end

    context "quand un hint est fourni" do
      let(:options) { { hint: "Formats acceptés : .mp3, .mp4" } }

      it "affiche le hint dans un span avec la classe fr-hint-text" do
        expect(html).to have_css("span.fr-hint-text", text: "Formats acceptés : .mp3, .mp4")
      end

      it "ajoute aria-describedby à l'input" do
        expect(html).to have_css("input[aria-describedby='transcription_audio-messages']")
      end
    end

    context "quand il n'y a pas de hint" do
      let(:options) { {} }

      it "n'affiche pas de span fr-hint-text" do
        expect(html).not_to have_css("span.fr-hint-text")
      end
    end

    context "quand il y a des erreurs" do
      before do
        object.errors.add(method, "doit être un fichier MP3 ou MP4")
      end

      it "ajoute la classe fr-upload-group--error au conteneur" do
        expect(html).to have_css("li.fr-upload-group.fr-upload-group--error")
      end

      it "affiche les erreurs dans le conteneur de messages" do
        expect(html).to have_css("div.fr-messages-group p.fr-message.fr-message--error",
                                 text: "doit être un fichier MP3 ou MP4")
      end

      it "ajoute aria-describedby à l'input même sans hint" do
        expect(html).to have_css("input[aria-describedby='transcription_audio-messages']")
      end
    end

    context "quand le champ est requis" do
      let(:options) { { required: true } }

      it "ajoute l'attribut required à l'input" do
        expect(html).to have_css("input[required]")
      end
    end

    context "quand un accept est fourni dans input_html" do
      let(:options) { { input_html: { accept: "audio/*" } } }

      it "utilise l'accept fourni" do
        expect(html).to have_css("input[accept='audio/*']")
      end
    end

    context "quand un id personnalisé est fourni" do
      let(:options) { { input_html: { id: "custom-id" } } }

      it "utilise l'id personnalisé" do
        expect(html).to have_css("input#custom-id")
        expect(html).to have_css("label[for='custom-id']")
        expect(html).to have_css("div#custom-id-messages")
      end
    end

    describe "structure HTML complète" do
      it "génère la structure dans le bon ordre" do
        expect(html).to have_css("li.fr-upload-group > label.fr-label")
        expect(html).to have_css("li.fr-upload-group > input.fr-upload")
        expect(html).to have_css("li.fr-upload-group > div.fr-messages-group")
      end
    end
  end

  describe "#input_id" do
    it "génère un id basé sur le nom de l'objet et la méthode" do
      expect(input.send(:input_id)).to eq("transcription_audio")
    end

    context "avec un id personnalisé" do
      let(:options) { { input_html: { id: "custom-id" } } }

      it "utilise l'id personnalisé" do
        expect(input.send(:input_id)).to eq("custom-id")
      end
    end
  end

  describe "#messages_id" do
    it "génère un id de messages basé sur l'input_id" do
      expect(input.send(:messages_id)).to eq("transcription_audio-messages")
    end
  end

  describe "#has_errors?" do
    context "quand il n'y a pas d'erreurs" do
      it "retourne false" do
        expect(input.send(:has_errors?)).to be false
      end
    end

    context "quand il y a des erreurs" do
      before do
        object.errors.add(method, "erreur de test")
      end

      it "retourne true" do
        expect(input.send(:has_errors?)).to be true
      end
    end
  end

  describe "#hint_text" do
    context "quand un hint est fourni" do
      let(:options) { { hint: "Indication importante" } }

      it "retourne le hint" do
        expect(input.send(:hint_text)).to eq("Indication importante")
      end
    end

    context "quand aucun hint n'est fourni" do
      let(:options) { {} }

      it "retourne nil" do
        expect(input.send(:hint_text)).to be_nil
      end
    end
  end
end
