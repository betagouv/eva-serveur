module Filtres
  class MenuComponent < ViewComponent::Base
    attr_reader :titre, :actifs, :valeur

    def initialize(titre:, actifs: 0, valeur: nil, application_immediate: false)
      @titre = titre
      @actifs = actifs
      @valeur = valeur
      @application_immediate = application_immediate
    end

    def application_immediate?
      @application_immediate
    end

    def libelle_bouton
      return @titre if @valeur.blank?

      I18n.t("components.filtres.titre_avec_valeur", titre: @titre, valeur: @valeur)
    end

    def actif?
      @valeur.present? || @actifs.positive?
    end

    def classe_bouton
      actif? ? "fr-btn--secondary" : "fr-btn--tertiary"
    end

    def compteur?
      @valeur.blank? && @actifs.positive?
    end

    def call
      content
    end
  end
end
