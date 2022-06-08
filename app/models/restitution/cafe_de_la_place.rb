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
      },
      'score_comprehention' => {
        'type' => :nombre,
        'parametre' => 'comprehention',
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
      {
        ::Competence::LECTURE_BAS => Competence::ProfileEvacob.new(self, 'score_lecture'),
        ::Competence::COMPREHENTION => Competence::ProfileEvacob.new(self, 'score_comprehention')
      }.transform_values(&:niveau)
    end
  end
end
