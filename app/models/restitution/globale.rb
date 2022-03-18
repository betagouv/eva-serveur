# frozen_string_literal: true

module Restitution
  class Globale
    attr_reader :evaluation, :restitutions

    NIVEAU_INDETERMINE = :indetermine
    RESTITUTION_SANS_EFFICIENCE = Restitution::Questions

    delegate :moyennes_metriques, :ecarts_types_metriques,
             to: :scores_niveau2_standardises, prefix: :niveau2
    delegate :moyennes_metriques, :ecarts_types_metriques,
             to: :scores_niveau1_standardises, prefix: :niveau1

    def initialize(evaluation:, restitutions:)
      @evaluation = evaluation
      @restitutions = restitutions
    end

    def persiste
      @evaluation.update interpretations
    end

    def utilisateur
      evaluation.nom
    end

    def date
      evaluation.created_at
    end

    def structure
      evaluation.campagne.compte.structure&.nom
    end

    def scores_niveau2
      @scores_niveau2 ||= Restitution::ScoresNiveau2.new(restitutions.map(&:partie))
    end

    def scores_niveau2_standardises
      @scores_niveau2_standardises ||= Restitution::ScoresStandardises.new(scores_niveau2)
    end

    def scores_niveau1
      @scores_niveau1 ||= Restitution::ScoresNiveau1.new(scores_niveau2_standardises)
    end

    def scores_niveau1_standardises
      @scores_niveau1_standardises ||= Restitution::ScoresStandardises.new(scores_niveau1)
    end

    delegate :synthese, to: :interpreteur_niveau1

    def interpretations_niveau1_cefr
      interpreteur_niveau1.interpretations_cefr
    end

    def interpretations_niveau1_anlci
      interpreteur_niveau1.interpretations_anlci
    end

    def interpreteur_niveau1
      @interpreteur_niveau1 ||= Illettrisme::InterpreteurNiveau1.new(
        Illettrisme::InterpreteurScores.new(scores_niveau1_standardises.calcule)
      )
    end

    def interpretations_niveau2(categorie)
      Illettrisme::InterpreteurNiveau2
        .new(scores_niveau2_standardises.calcule)
        .interpretations(categorie)
    end

    def interpretations
      {
        synthese_competences_de_base: interpreteur_niveau1.synthese,
        niveau_cefr: interpreteur_niveau1.interpretations_cefr[:litteratie],
        niveau_cnef: interpreteur_niveau1.interpretations_cefr[:numeratie],
        niveau_anlci_litteratie: interpreteur_niveau1.interpretations_anlci[:litteratie],
        niveau_anlci_numeratie: interpreteur_niveau1.interpretations_anlci[:numeratie]
      }
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

    def interpretations_competences_transversales
      CompetencesTransversales::Interpreteur.new(niveaux_competences).interpretations
    end

    def niveaux_competences
      extraie_competences_depuis_restitutions.sort_by { |_, niveau| -niveau }
    end

    def competences
      niveaux_competences.collect { |competence, _| competence }
    end

    private

    def extraie_competences_depuis_restitutions
      moyenne_competences.each_with_object([]) do |(competence, niveaux), memo|
        memo << [competence, niveaux.sum.fdiv(niveaux.size)]
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
  end
end
