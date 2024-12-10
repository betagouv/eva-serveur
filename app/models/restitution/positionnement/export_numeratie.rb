# frozen_string_literal: true

module Restitution
  module Positionnement
    class ExportNumeratie
      def initialize(partie, sheet)
        @partie = partie
        @evenements_reponses = Evenement.where(session_id: @partie.session_id).reponses
        @sheet = sheet
      end

      def regroupe_par_codes_clea
        questions_classees = questions_repondues_et_non_repondues.group_by do |e|
          Metacompetence.new(e['metacompetence']).code_clea_sous_domaine
        end

        questions_classees.transform_values do |groupes|
          groupes.group_by do |e|
            Metacompetence.new(e['metacompetence']).code_clea_sous_sous_domaine
          end
        end
      end

      def questions_non_repondues
        questionnaire = Questionnaire.find_by(id: @partie.situation.questionnaire)
        return [] unless questionnaire&.questions

        questionnaire.questions.reject do |q|
          @evenements_reponses.questions_repondues.include?(q[:nom_technique]) ||
            question_rattrapage(q[:nom_technique]) || q.sous_consigne?
        end
      end

      def questions_repondues_et_non_repondues
        non_repondues = questions_non_repondues.map(&:as_json).each do |q|
          q['scoreMax'] = q.delete('score')
          q['question'] = q.delete('nom_technique')
        end
        @evenements_reponses.map(&:donnees) + non_repondues
      end

      def remplis_reponses(ligne, reponses)
        reponses.each do |reponse|
          question = Question.find_by(nom_technique: reponse['question'])
          ligne = remplis_ligne(ligne, reponse, question)
        end
        ligne
      end

      def remplis_ligne(ligne, donnees, question)
        code = Metacompetence.new(donnees['metacompetence']).code_clea_sous_sous_domaine
        @sheet.row(ligne).replace([code,
                                   donnees['question'],
                                   donnees['metacompetence']&.humanize,
                                   question&.interaction,
                                   donnees['intitule']])
        remplis_choix(ligne, donnees, question)
        remplis_score(ligne, donnees)
        ligne + 1
      end

      def remplis_score(ligne, evenement)
        @sheet[ligne, 8] = evenement['score'].to_s
        @sheet[ligne, 9] = evenement['scoreMax'].to_s
      end

      def remplis_choix(ligne, donnees, question)
        @sheet[ligne, 5] = question&.interaction == 'qcm' ? question&.liste_choix : nil
        @sheet[ligne, 6] = question&.bonnes_reponses if question&.qcm? || question&.saisie?
        @sheet[ligne, 7] = donnees['reponseIntitule'] || donnees['reponse']
      end

      def question_rattrapage(nom_technique)
        nom_technique.start_with?('N1R', 'N2R', 'N3R')
      end
    end
  end
end
