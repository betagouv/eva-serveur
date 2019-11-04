# frozen_string_literal: true

module Restitution
  class Globale
    attr_reader :restitutions, :evaluation

    NIVEAU_INDETERMINE = :indetermine

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
      return 0 if restitutions.blank?

      efficiences = restitutions.collect(&:efficience).compact
      return NIVEAU_INDETERMINE if efficiences.include?(NIVEAU_INDETERMINE) || efficiences.blank?

      efficiences.inject(0.0) { |somme, efficience| somme + efficience } / efficiences.size
    end

    def competences_meilleure_restitution
      meilleure_restitution&.competences_mobilisees || []
    end

    def meilleure_restitution
      @restitutions.reject do |restitution|
        restitution.competences_mobilisees.blank? ||
          restitution.efficience == NIVEAU_INDETERMINE
      end.max_by(&:efficience)
    end

    def competences
      extraie_competences_depuis_restitutions.sort_by do |niveau_competence|
        -niveau_competence.values.first
      end
    end

    private

    def extraie_competences_depuis_restitutions
      competences_max.each_with_object([]) do |(competence, niveau), memo|
        memo << { competence => niveau }
      end
    end

    def competences_max
      @restitutions.each_with_object({}) do |restitution, memo|
        restitution.competences.each do |competence, niveau|
          next if niveau == NIVEAU_INDETERMINE ||
                  Base::COMPETENCES_INUTILES_POUR_EFFICIENCE.include?(competence)

          memo[competence] = niveau if (memo[competence] || 0) < niveau
        end
        memo
      end
    end
  end
end
