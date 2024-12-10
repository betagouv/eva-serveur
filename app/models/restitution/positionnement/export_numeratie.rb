# frozen_string_literal: true

module Restitution
  module Positionnement
    class ExportNumeratie
      def initialize(partie, sheet)
        @partie = partie
        @evenements_reponses = Evenement.where(session_id: @partie.session_id).reponses
        @sheet = sheet
      end

      def regroupe_par_code_clea
        repondues_et_non_repondues(questions_non_repondues.map(&:as_json),
                                   @evenements_reponses.map(&:donnees))
          .group_by do |e|
          Metacompetence.code_clea(e['metacompetence'])
        end
      end

      def questions_non_repondues
        questionnaire = Questionnaire.find_by(id: @partie.situation.questionnaire)
        return [] unless questionnaire&.questions

        questionnaire.questions.reject do |q|
          @evenements_reponses.questions_repondues.include?(q[:nom_technique]) ||
            q[:nom_technique].start_with?('N1R', 'N2R', 'N3R') || q.sous_consigne?
        end
      end

      def repondues_et_non_repondues(non_repondues, repondues)
        non_repondues.each do |q|
          q['scoreMax'] = q.delete('score')
          q['question'] = q.delete('nom_technique')
        end
        repondues + non_repondues
      end

      def remplis_reponses_par_code(ligne, evenements, code = nil)
        @sheet[ligne, 0] = "#{code} - score: #{pourcentage_reussite(evenements)}"
        ligne += 1
        remplis_reponses(ligne, evenements)
      end

      def pourcentage_reussite(evenements)
        scores = evenements.map { |e| [e['scoreMax'] || 0, e['score'] || 0] }
        score_max, score = scores.transpose.map(&:sum)
        score_max.zero? ? 'non applicable' : "#{(score * 100 / score_max).round}%"
      end

      def remplis_reponses(ligne, evenements)
        evenements.each do |evenement|
          ligne = remplis_ligne(ligne, evenement)
        end
        ligne
      end

      def remplis_ligne(ligne, evenement)
        remplis_numeratie(ligne, evenement)
        ligne + 1
      end

      def remplis_numeratie(ligne, donnees)
        question = Question.find_by(nom_technique: donnees['question'])
        @sheet.row(ligne).replace([Metacompetence.code_clea(donnees['metacompetence']),
                                   donnees['question'],
                                   donnees['metacompetence']&.humanize,
                                   question&.interaction,
                                   donnees['intitule']])
        remplis_choix(ligne, donnees, question)
        remplis_score(ligne, donnees)
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
    end
  end
end
