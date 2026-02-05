require "rails_helper"

describe LienComponent, type: :component do
  let(:body) { "Mon lien" }
  let(:url) { "https://example.com" }

  describe "@params quand externe est true" do
    subject(:component) do
      described_class.new(body, url, externe: true)
    end

    it "n'ajoute pas target _blank" do
      expect(component.instance_variable_get(:@params)[:target]).not_to eq("_blank")
    end

    it "ajoute rel noopener external" do
      expect(component.instance_variable_get(:@params)[:rel]).to eq("noopener external")
    end

    it "n'ajoute pas le title" do
      expect(component.instance_variable_get(:@params)[:title]).to be_nil
    end
  end

  describe "quand aria label est présent" do
    subject(:component) do
      described_class.new(body, url, aria: { label: aria_label })
    end

    let(:aria_label) { "Label accessible" }

    it "met à jour aria label avec la description externe" do
      expect(component.instance_variable_get(:@params)[:aria][:label]).to eq(aria_label)
    end
  end

  describe "@params quand nouvelle_fenetre est true" do
    subject(:component) do
      described_class.new(body, url, nouvelle_fenetre: true)
    end

    it "ajoute target _blank" do
      expect(component.instance_variable_get(:@params)[:target]).to eq("_blank")
    end

    it "ajoute rel noopener external" do
      expect(component.instance_variable_get(:@params)[:rel]).to eq("noopener external")
    end

    it "ajoute le title avec la description externe" do
      description_attendue = I18n.t(".lien_externe", texte_du_lien: body)
      expect(component.instance_variable_get(:@params)[:title]).to eq(description_attendue)
    end

    context "quand aria label est présent" do
      subject(:component) do
        described_class.new(body, url, nouvelle_fenetre: true, aria: { label: aria_label })
      end

      let(:aria_label) { "Label accessible" }

      it "met à jour aria label avec la description externe" do
        description_attendue = I18n.t(".lien_externe", texte_du_lien: aria_label)
        expect(component.instance_variable_get(:@params)[:aria][:label]).to eq(description_attendue)
      end
    end
  end
end
