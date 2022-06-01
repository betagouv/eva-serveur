# frozen_string_literal: true

module Restitution
  class CafeDeLaPlace < Base
    METRIQUES = {
      'score_orientation' => {
        'type' => :nombre,
        'module' => :orientation,
        'instance' => Illettrisme::ScoreModule.new
      },
      'score_lecture' => {
        'type' => :nombre,
        'module' => :lecture_complet,
        'instance' => Illettrisme::ScoreModule.new
      }
    }.freeze

    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementEvacob.new e }
      super(campagne, evenements)
    end

    METRIQUES.each_key do |metrique|
      define_method metrique do
        METRIQUES[metrique]['instance']
          .calcule(evenements, METRIQUES[metrique]['module'])
      end
    end

    def efficience
      nil
    end

    def competences
      calcule_competences(
        ::Competence::LECTURE_BAS => CafeDeLaPlace::LectureBas
      )
    end
  end
end
