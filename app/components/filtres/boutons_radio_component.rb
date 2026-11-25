module Filtres
  class BoutonsRadioComponent < ViewComponent::Base
    def initialize(nom:, libelle:, options:, valeur: nil)
      @nom = nom
      @libelle = libelle
      @options = [ [ I18n.t("components.filtres.toutes"), "" ] ] + options
      @valeur = valeur.to_s
    end

    def tags
      @options.select { |_libelle, valeur| valeur.present? && valeur.to_s == @valeur }
              .map { |libelle, valeur| Tag.new(libelle: libelle, nom: @nom.to_s,
valeur: valeur.to_s) }
    end

    def identifiant(valeur)
      "#{@nom.to_s.delete(']').tr('[', '_')}_#{valeur.presence || 'toutes'}"
    end
  end
end
