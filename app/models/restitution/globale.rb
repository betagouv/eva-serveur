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

    def competences
      competences_non_triees = extraie_competences_depuis_restitutions
      competences_triees = competences_non_triees.sort_by do |niveau_competence|
        -niveau_competence.values.first
      end
      filtre_les_competences_en_double competences_triees
    end

    private

    def extraie_competences_depuis_restitutions
      @restitutions.collect do |restitution|
        restitution.competences.collect do |competence, niveau|
          next if niveau == NIVEAU_INDETERMINE

          { competence => niveau }
        end
      end.flatten.compact
    end

    def filtre_les_competences_en_double(niveaux_competences)
      resultat = []
      niveaux_competences.each do |niveau_competence|
        next if resultat.any? { |nc| nc.keys == niveau_competence.keys }

        resultat << niveau_competence
      end
      resultat
    end
  end
end
