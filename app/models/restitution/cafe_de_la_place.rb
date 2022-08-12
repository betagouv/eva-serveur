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
      'score_comprehension' => {
        'type' => :nombre,
        'parametre' => 'comprehension',
        'instance' => Evacob::ScoreMetacompetence.new
      },
      'score_production' => {
        'type' => :nombre,
        'parametre' => 'production',
        'instance' => Evacob::ScoreMetacompetence.new
      },
      'score_hpar' => {
        'type' => :nombre,
        'parametre' => :hpar,
        'instance' => Evacob::ScoreModule.new
      },
      'score_hgac' => {
        'type' => :nombre,
        'parametre' => :hgac,
        'instance' => Evacob::ScoreModule.new
      },
      'score_hcvf' => {
        'type' => :nombre,
        'parametre' => :hcvf,
        'instance' => Evacob::ScoreModule.new
      },
      'score_hpfb' => {
        'type' => :nombre,
        'parametre' => :hpfb,
        'instance' => Evacob::ScoreModule.new
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

    def parcours_bas
      profils = competences.values
      return ::Competence::NIVEAU_INDETERMINE if profils.include?(::Competence::NIVEAU_INDETERMINE)

      position_minimum = profils.map do |profil|
        ::Competence::PROFILS.index(profil)
      end.min
      ::Competence::PROFILS[position_minimum]
    end

    def synthese
      {
        parcours_bas: parcours_bas
      }
    end

    def competences
      @competences ||= {
        lecture_bas: Competence::ProfilEvacob.new(self, 'score_lecture'),
        comprehension: Competence::ProfilEvacob.new(self, 'score_comprehension'),
        production: Competence::ProfilEvacob.new(self, 'score_production')
      }.transform_values(&:niveau)
    end
  end
end
