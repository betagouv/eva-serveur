# frozen_string_literal: true

require "rails_helper"
require "rubocop"
require "rubocop/rspec/support"
require Rails.root.join("lib/rubocop/cop/dsfr/bouton_copier_tertiaire").to_s

describe RuboCop::Cop::Dsfr::BoutonCopierTertiaire, :config do
  include RuboCop::RSpec::ExpectOffense

  describe "BoutonDsfrComponent" do
    it "signale un bouton copier sans type (primaire par défaut)" do
      expect_offense(<<~RUBY)
        BoutonDsfrComponent.new(url, tag: :button).with_content(t(".copier_code"))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Un bouton « Copier… » doit être tertiaire (`type: :tertiary`).
      RUBY
    end

    it "signale un bouton copier secondaire au libellé écrit en dur" do
      expect_offense(<<~RUBY)
        BoutonDsfrComponent.new(url, tag: :button, type: :secondary).with_content("Copier l'URL")
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Un bouton « Copier… » doit être tertiaire (`type: :tertiary`).
      RUBY
    end

    it "accepte un bouton copier tertiaire" do
      expect_no_offenses(<<~RUBY)
        BoutonDsfrComponent.new(url, tag: :button, type: :tertiary).with_content(I18n.t("actions.copier_url"))
      RUBY
    end

    it "accepte un bouton copier tertiaire sans bordure" do
      expect_no_offenses(<<~RUBY)
        BoutonDsfrComponent.new(url, tag: :button, type: :tertiary_no_outline).with_content("Copier")
      RUBY
    end

    it "accepte un autre libellé primaire" do
      expect_no_offenses(<<~RUBY)
        BoutonDsfrComponent.new(url, tag: :button).with_content(t(".enregistrer"))
      RUBY
    end
  end

  describe "button_tag" do
    it "signale un bouton copier secondaire" do
      expect_offense(<<~RUBY)
        button_tag t(".copier_code"), class: "fr-btn fr-btn--secondary"
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Un bouton « Copier… » doit être tertiaire (`type: :tertiary`).
      RUBY
    end

    it "accepte un bouton copier tertiaire" do
      expect_no_offenses(<<~RUBY)
        button_tag "Copier", class: "fr-btn fr-btn--tertiary"
      RUBY
    end
  end
end
