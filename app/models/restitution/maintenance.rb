# frozen_string_literal: true

module Restitution
  class Maintenance < AvecEntrainement
    def nombre_erreurs
      Metriques::MAINTENANCE['nombre_erreurs']
        .new(evenements_situation)
        .calcule
    end
  end
end
