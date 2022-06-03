# frozen_string_literal: true

module Restitution
  class CafeDeLaPlace < Base
    METRIQUES = {
      'score_orientation' => {
        'type' => :nombre,
        'parametre' => :orientation,
        'instance' => Evacob::ScoreModule.new
      },
      'score_lecture' => {
        'type' => :nombre,
        'parametre' => 'lecture',
        'instance' => Evacob::ScoreMetacompetence.new
      }
    }.freeze

    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementEvacob.new e }
      super(campagne, evenements)
    end

    METRIQUES.each_key do |metrique|
      define_method metrique do
        METRIQUES[metrique]['instance']
          .calcule(evenements, METRIQUES[metrique]['parametre'])
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
