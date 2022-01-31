# frozen_string_literal: true

module Restitution
  class CafeDeLaPlace < Base
    METRIQUES = {
      'nombre_reponses' => {
        'type' => :nombre,
        'instance' => Illettrisme::NombreReponses.new
      },
      'score' => {
        'type' => :nombre,
        'instance' => Illettrisme::NombreBonnesReponses.new
      }
    }.freeze

    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementEvacob.new e }
      super(campagne, evenements)
    end

    METRIQUES.each_key do |metrique|
      define_method metrique do
        METRIQUES[metrique]['instance']
          .calcule(evenements, 'toutes')
      end
    end

    def efficience
      nil
    end
  end
end
