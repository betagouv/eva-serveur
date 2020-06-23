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

    delegate :scores, to: :calculateur_scores_evaluation

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

    def calculateur_scores_evaluation
      Restitution::CalculateurScoresEvaluation.new(restitutions.map(&:partie),
                                                   standardisateurs,
                                                   METRIQUES_ILLETRISME)
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

    def standardisateurs
      @standardisateurs ||= restitutions.each_with_object({}) do |r, memo|
        memo[r.partie.situation] ||= Restitution::Standardisateur.new(
          METRIQUES_ILLETRISME,
          proc { Partie.where(situation: r.partie.situation) }
        )
      end
    end
  end
end
