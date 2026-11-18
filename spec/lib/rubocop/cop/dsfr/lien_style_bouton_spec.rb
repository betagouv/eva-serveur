# frozen_string_literal: true

require "rails_helper"
require "rubocop"
require "rubocop/rspec/support"
require Rails.root.join("lib/rubocop/cop/dsfr/lien_style_bouton").to_s

describe RuboCop::Cop::Dsfr::LienStyleBouton, :config do
  include RuboCop::RSpec::ExpectOffense

  describe "lien écrit à la main avec la classe fr-btn" do
    it "signale link_to avec fr-btn" do
      expect_offense(<<~RUBY)
        link_to "Voir", campagne_path, class: "fr-btn fr-btn--secondary"
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Un lien ne doit pas porter la classe `fr-btn` : utilisez `BoutonDsfrComponent` pour une action, ou `fr-link` pour une consultation.
      RUBY
    end

    it "signale link_to_if avec fr-btn dans une interpolation" do
      expect_offense(<<~'RUBY')
        link_to_if ok, "Voir", chemin, class: "fr-btn #{classe}"
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Un lien ne doit pas porter la classe `fr-btn` : utilisez `BoutonDsfrComponent` pour une action, ou `fr-link` pour une consultation.
      RUBY
    end

    it "signale fr-btn dans un hash fusionné" do
      expect_offense(<<~RUBY)
        link_to label, url, { class: "fr-btn" }.merge(attributs)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Un lien ne doit pas porter la classe `fr-btn` : utilisez `BoutonDsfrComponent` pour une action, ou `fr-link` pour une consultation.
      RUBY
    end

    it "accepte un lien fr-link" do
      expect_no_offenses(<<~RUBY)
        link_to "Voir", campagne_path, class: "fr-link"
      RUBY
    end

    it "accepte un button_tag fr-btn" do
      expect_no_offenses(<<~RUBY)
        button_tag "Envoyer", class: "fr-btn"
      RUBY
    end

    it "ne confond pas fr-btns-group avec fr-btn" do
      expect_no_offenses(<<~RUBY)
        link_to "Voir", chemin, class: "fr-btns-group"
      RUBY
    end
  end

  describe "bouton dont le libellé désigne une consultation" do
    it "signale une clé i18n voir_tout" do
      expect_offense(<<~RUBY)
        BoutonDsfrComponent.new(url, tag: :a).with_content(t(".voir_tout"))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Un bouton ne doit pas mener à un contenu à consulter : utilisez `LienComponent`.
      RUBY
    end

    it "signale une clé i18n absolue consulter_diagnostic" do
      expect_offense(<<~RUBY)
        BoutonDsfrComponent.new(url, tag: :a).with_content(I18n.t("admin.dashboard.consulter_diagnostic"))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Un bouton ne doit pas mener à un contenu à consulter : utilisez `LienComponent`.
      RUBY
    end

    it "signale un libellé écrit en dur avec accent" do
      expect_offense(<<~RUBY)
        BoutonDsfrComponent.new(url, tag: :a).with_content("Détail de l'évaluation")
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Un bouton ne doit pas mener à un contenu à consulter : utilisez `LienComponent`.
      RUBY
    end

    it "accepte un libellé d'action" do
      expect_no_offenses(<<~RUBY)
        BoutonDsfrComponent.new(url, tag: :a).with_content(t(".tester_campagne"))
      RUBY
    end

    it "accepte un with_content sur un autre composant" do
      expect_no_offenses(<<~RUBY)
        LienComponent.new(url).with_content(t(".voir_tout"))
      RUBY
    end
  end
end
