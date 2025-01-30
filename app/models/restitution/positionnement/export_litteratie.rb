# frozen_string_literal: true
# rubocop:disable all

module Restitution
  module Positionnement
    class ExportLitteratie
      attr_reader :evenements_questions

      def initialize(partie, onglet_xls)
        super()
        @partie = partie
        evenements_reponses = Evenement.where(session_id: @partie.session_id)
                                       .reponses
                                       .order(:position)

        questions = Question.where(nom_technique: evenements_reponses.map do |evenement|
          evenement.donnees['question']
        end).order(:nom_technique)

        @evenements_questions = evenements_reponses.map do |evenement|
          question = questions.find do |question|
            evenement.donnees['question'] == question.nom_technique
          end
          EvenementQuestion.new(question: question, evenement: evenement)
        end

        @onglet_xls = onglet_xls
        @temps_par_question = Restitution::Metriques::TempsPasseParQuestion
                              .new(@partie.evenements).calculer
      end

      def remplis_reponses(ligne)
        @evenements_questions.each do |evenement_question|
          ligne = remplis_ligne(ligne, evenement_question)
        end
        ligne
      end

      def remplis_ligne(ligne, evenement_question)
        @onglet_xls.set_valeur(ligne, 0, evenement_question.nom_technique)
        @onglet_xls.set_valeur(ligne, 1, evenement_question.intitule)
        @onglet_xls.set_valeur(ligne, 2, evenement_question.reponse)
        @onglet_xls.set_nombre(ligne, 3, evenement_question.score)
        @onglet_xls.set_nombre(ligne, 4, evenement_question.score_max)
        @onglet_xls.set_valeur(ligne, 5, evenement_question.metacompetence)
        @onglet_xls.set_valeur(ligne, 6, @temps_par_question[evenement_question.nom_technique])
        ligne + 1
      end
    end
  end
end
