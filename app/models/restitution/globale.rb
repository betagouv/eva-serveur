# frozen_string_literal: true

module Restitution
  class Globale
    attr_reader :evaluation, :restitutions, :synthese_positionnement, :synthese_diagnostic,
                :synthese_positionnement_numeratie, NIVEAU_INDETERMINE = :indetermine

    delegate :moyennes_metriques, :ecarts_types_metriques,
             to: :scores_niveau2_standardises, prefix: :niveau2
    delegate :moyennes_metriques, :ecarts_types_metriques, to: :scores_niveau1_standardises,
                                                           prefix: :niveau1
    delegate :synthese, :synthese_positionnement, :synthese_diagnostic,
             :synthese_positionnement_numeratie, :niveau_anlci_litteratie, to: :synthetiseur

    def initialize(evaluation:, restitutions:)
      @evaluation = evaluation
      @restitutions = restitutions
    end

    def persiste
      restitution_complete = Restitution::Completude.new(evaluation, restitutions).calcule
      @evaluation.update interpretations.merge(completude: restitution_complete)
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

    def synthetiseur
      @synthetiseur ||= Illettrisme::Synthetiseur.new(interpreteur_niveau1, litteratie, numeratie)
    end

    def interpretations_niveau2(categorie)
      Illettrisme::InterpreteurNiveau2
        .new(scores_niveau2_standardises.calcule).interpretations(categorie)
    end

    def interpretations
      { synthese_competences_de_base: synthese,
        niveau_cefr: interpreteur_niveau1.interpretations_cefr[:litteratie],
        niveau_cnef: interpreteur_niveau1.interpretations_cefr[:numeratie],
        niveau_anlci_litteratie: interpreteur_niveau1.interpretations_anlci[:litteratie],
        niveau_anlci_numeratie: interpreteur_niveau1.interpretations_anlci[:numeratie],
        positionnement_niveau_litteratie: synthetiseur.positionnement_litteratie,
        positionnement_niveau_numeratie: synthetiseur.positionnement_numeratie }
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

    def selectionne_derniere_restitution(nom)
      restitutions.reverse.find { |restitution| restitution.situation.nom_technique == nom }
    end

    private

    def litteratie
      @litteratie ||= selectionne_derniere_restitution(Situation::CAFE_DE_LA_PLACE)
    end

    def numeratie
      @numeratie ||= selectionne_derniere_restitution(Situation::PLACE_DU_MARCHE)
    end

    def extraie_competences_depuis_restitutions
      moyenne_competences.each_with_object([]) do |(competence, niveaux), memo|
        memo << [ competence, niveaux.sum.fdiv(niveaux.size) ]
      end
    end

    def moyenne_competences
      @restitutions.each_with_object({}) do |restitution, memo|
        restitution.competences.each do |competence, niveau|
          next if niveau == NIVEAU_INDETERMINE ||
                  ::Competence::COMPETENCES_TRANSVERSALES.exclude?(competence)

          memo[competence] ||= []
          memo[competence] << niveau
        end
        memo
      end
    end
  end
end
