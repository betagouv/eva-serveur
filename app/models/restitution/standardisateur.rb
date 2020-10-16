# frozen_string_literal: true

module Restitution
  class Standardisateur
    def standardise(metrique, valeur)
      return if valeur.nil? || ecart_type_metriques[metrique].nil?

      if ecart_type_metriques[metrique].zero?
        0
      else
        (
          (valeur - moyenne_metriques[metrique]) / ecart_type_metriques[metrique]
        )
      end
    end
  end
end
