module Restitution
  class Standardisateur
    def standardise(metrique, valeur)
      return if valeur.nil? || ecarts_types_metriques[metrique].nil?

      if ecarts_types_metriques[metrique].zero?
        0
      else
        (
          (valeur - moyennes_metriques[metrique]) / ecarts_types_metriques[metrique]
        )
      end
    end
  end
end
