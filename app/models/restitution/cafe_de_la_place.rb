module Restitution
  class CafeDeLaPlace < Base
    METRIQUES = {
      "score_orientation" => {
        "type" => :nombre,
        "parametre" => :orientation,
        "instance" => Evacob::ScoreModule.new
      },
      "score_lecture" => {
        "type" => :nombre,
        "parametre" => "lecture",
        "instance" => Evacob::ScoreMetacompetence.new
      },
      "score_comprehension" => {
        "type" => :nombre,
        "parametre" => "comprehension",
        "instance" => Evacob::ScoreMetacompetence.new
      },
      "score_production" => {
        "type" => :nombre,
        "parametre" => "production",
        "instance" => Evacob::ScoreMetacompetence.new
      },
      "score_hpar" => {
        "type" => :nombre,
        "parametre" => :hpar,
        "instance" => Evacob::ScoreModule.new
      },
      "score_hgac" => {
        "type" => :nombre,
        "parametre" => :hgac,
        "instance" => Evacob::ScoreModule.new
      },
      "score_hcvf" => {
        "type" => :nombre,
        "parametre" => :hcvf,
        "instance" => Evacob::ScoreModule.new
      },
      "score_hpfb" => {
        "type" => :nombre,
        "parametre" => :hpfb,
        "instance" => Evacob::ScoreModule.new
      }
    }.freeze

    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementEvacob.new e }
      super
    end

    def complete?
      evenements.any?(&:fin_situation?)
    end

    METRIQUES.each_key do |metrique|
      define_method metrique do
        METRIQUES[metrique]["instance"]
          .calcule(evenements, METRIQUES[metrique]["parametre"])
      end
    end

    def parcours_bas
      profils = competences_litteratie.values.map { |competence| competence.profil.to_sym }
      return ::Competence::NIVEAU_INDETERMINE if profils.include?(::Competence::NIVEAU_INDETERMINE)

      position_minimum = profils.map do |profil|
        ::Competence::PROFILS_BAS.index(profil)
      end.min
      ::Competence::PROFILS_BAS[position_minimum]
    end

    def parcours_haut
      scores = scores_parcours_haut.values
      return ::Competence::NIVEAU_INDETERMINE if scores.include?(nil)

      Competence::ProfilEvacob.new(self, "score_parcours_haut", scores.sum).niveau
    end

    def niveau_litteratie
      return parcours_haut if parcours_haut != ::Competence::NIVEAU_INDETERMINE

      parcours_bas
    end
    alias_method :profil, :niveau_litteratie

    def synthese
      {
        parcours_bas: parcours_bas,
        parcours_haut: parcours_haut,
        niveau_litteratie: niveau_litteratie
      }
    end

    def competences_litteratie
      @competences_litteratie ||= %i[lecture comprehension production]
                                  .index_with do |comp|
        Restitution::SousCompetence::Litteratie.new(profil: competence(comp).niveau)
      end
    end

    def competence(comp)
      Competence::ProfilEvacob.new(self, "score_#{comp}")
    end

    def scores_parcours_haut
      @scores_parcours_haut ||= {
        hpar: partie.metriques["score_hpar"],
        hgac: partie.metriques["score_hgac"],
        hcvf: partie.metriques["score_hcvf"],
        hpfb: partie.metriques["score_hpfb"]
      }
    end
  end
end
