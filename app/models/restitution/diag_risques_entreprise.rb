# frozen_string_literal: true

module Restitution
  class DiagRisquesEntreprise < Base
    METRIQUES = {
      "pourcentage_risque" => {
        "type" => :nombre,
        "instance" => Restitution::Entreprises::PourcentageRisque.new
      }
    }

    METRIQUES.each_key do |metrique|
      define_method metrique do
        METRIQUES[metrique]["instance"]
          .calcule(@evenements)
      end
    end
  end
end
