module Filtres
  # Un menu de la barre de filtres : ses composants de filtres donnent leurs champs et les
  # valeurs choisies (tags), dont le menu tire son compteur.
  class MenuComponent < ViewComponent::Base
    attr_reader :titre

    def initialize(titre:, filtres: [], application_immediate: false)
      @titre = titre
      @filtres = filtres
      @application_immediate = application_immediate
    end

    def tags
      @filtres.flat_map(&:tags)
    end

    def application_immediate?
      @application_immediate
    end

    def actif?
      tags.any?
    end

    def classe_bouton
      actif? ? "fr-btn--secondary" : "fr-btn--tertiary"
    end

    def call
      safe_join(@filtres.map { |filtre| render(filtre) }) + content.to_s
    end
  end
end
