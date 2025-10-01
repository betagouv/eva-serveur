require "rails_helper"

describe MarkdownHelper do
  describe "#md" do
    it "retourne une chaine vide pour nil" do
      expect(helper.md(nil)).to eq ""
    end

    it "retourne le contenu traduit en html" do
      expect(helper.md("*évaluer les compétences*"))
        .to match("<p><em>évaluer les compétences</em></p>")
    end

    it "retourne le contenu traduit en html avec une font-weight customisé" do
      html =
        '<p><strong class="fw-semi-bold">évaluer les compétences</strong> transversales</p>'
      expect(helper.md("**évaluer les compétences** transversales")).to match(html)
    end

    it "Les section de code ne traduisent pas les caractères markdown" do
      expect(helper.md("`du code avec des caractères _markdown_`"))
        .to match("<code>du code avec des caractères _markdown_</code>")
    end
  end
end
