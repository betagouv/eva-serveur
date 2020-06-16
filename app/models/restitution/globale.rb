# frozen_string_literal: true

module Restitution
  class Globale
    attr_reader :restitutions, :evaluation

    NIVEAU_INDETERMINE = :indetermine
    RESTITUTION_SANS_EFFICIENCE = Restitution::Questions

    METRIQUES_ILLETRISME = %i[score_ccf
                              score_numeratie
                              score_syntaxe_orthographe
                              score_memorisation].freeze

    def initialize(restitutions:, evaluation:)
      @restitutions = restitutions
      @evaluation = evaluation
    end

    def utilisateur
      evaluation.nom
    end

    def date
      evaluation.created_at
    end

    def efficience
      restitutions_selectionnee = restitutions.reject do |restitution|
        restitution.is_a? RESTITUTION_SANS_EFFICIENCE
      end
      return 0 if restitutions_selectionnee.blank?

      efficiences = restitutions_selectionnee.collect(&:efficience).compact
      return NIVEAU_INDETERMINE if efficiences.include?(NIVEAU_INDETERMINE) || efficiences.blank?

      efficiences.inject(0.0) { |somme, efficience| somme + efficience } / efficiences.size
    end

    def niveaux_competences
      extraie_competences_depuis_restitutions.sort_by do |niveau_competence|
        -niveau_competence.values.first
      end
    end

    def competences
      niveaux_competences.collect { |niveau_competence| niveau_competence.keys.first }
    end

    def scores
      scores = {}
      valeurs_des_metriques(standardiseurs).each do |metrique, valeurs|
        scores[metrique] = valeurs.sum.fdiv(valeurs.count)
      end
      scores
    end

    private

    def extraie_competences_depuis_restitutions
      moyenne_competences.each_with_object([]) do |(competence, niveaux), memo|
        memo << { competence => niveaux.sum.to_f / niveaux.size }
      end
    end

    def moyenne_competences
      @restitutions.each_with_object({}) do |restitution, memo|
        restitution.competences.each do |competence, niveau|
          next if niveau == NIVEAU_INDETERMINE ||
                  Base::COMPETENCES_INUTILES_POUR_EFFICIENCE.include?(competence)

          memo[competence] ||= []
          memo[competence] << niveau
        end
        memo
      end
    end

    def valeurs_des_metriques(standardiseurs)
      METRIQUES_ILLETRISME.each_with_object({}) do |metrique, memo|
        restitutions.each do |r|
          cote_z = standardise(standardiseurs, r.partie, metrique)
          next if cote_z.nil?

          memo[metrique] ||= []
          memo[metrique] << cote_z
        end
        memo
      end
    end

    def standardise(standardiseurs, partie, metrique)
      standardiseurs[partie.situation].standardise(metrique, partie.metriques[metrique.to_s])
    end

    def standardiseurs
      @standardiseurs ||= restitutions.each_with_object({}) do |restitution, memo|
        memo[restitution.partie.situation] ||= Restitution::Standardisateur.new(
          METRIQUES_ILLETRISME,
          proc { Partie.where(situation: restitution.partie.situation) }
        )
      end
    end
  end
end
