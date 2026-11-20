module Filtres
  class BoutonsRadioComponent < ViewComponent::Base
    def initialize(nom:, libelle:, options:, valeur: nil)
      @nom = nom
      @libelle = libelle
      @options = [ [ I18n.t("components.filtres.toutes"), "" ] ] + options
      @valeur = valeur.to_s
    end

    def identifiant(valeur)
      "#{@nom}_#{valeur.presence || 'toutes'}"
    end
  end
end
