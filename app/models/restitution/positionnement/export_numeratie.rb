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
        groupes_clea = regroupe_par_sous_domaine
        regroupe_par_sous_sous_domaine(groupes_clea)
      end

      def questions_non_repondues
        questionnaire = Questionnaire.find_by(id: @partie.situation.questionnaire)
        return [] unless questionnaire&.questions

        questionnaire.questions.reject do |q|
          @evenements_reponses.questions_repondues.include?(q[:nom_technique]) ||
            q.sous_consigne?
        end
      end

      def remplis_sous_domaine(ligne, code, reponses)
        pourcentage = pourcentage_reussite(reponses_filtres(reponses))
        intitule_code_cle = Metacompetence::CODECLEA_INTITULES[code]
        @sheet[ligne, 0] =
          "#{code} - #{intitule_code_cle} - score: #{pourcentage}"
      end

      def remplis_sous_sous_domaine(ligne, sous_code, reponses)
        pourcentage = pourcentage_reussite(reponses_filtres(reponses))
        @sheet[ligne, 0] = "#{sous_code} - score: #{pourcentage}"
      end

      def remplis_reponses(ligne, reponses)
        reponses.each do |reponse|
          question = Question.find_by(nom_technique: reponse['question'])
          ligne = remplis_ligne(ligne, reponse, question)
        end
        ligne
      end

      private

      def regroupe_par_sous_domaine
        groupes_clea = questions_repondues_et_non_repondues.group_by do |e|
          Metacompetence.new(e['metacompetence']).code_clea_sous_domaine
        end
        tri_par_ordre_croissant(groupes_clea)
      end

      def regroupe_par_sous_sous_domaine(groupes_clea)
        groupes_clea.transform_values do |groupes|
          sous_groupes_clea = groupes.group_by do |e|
            Metacompetence.new(e['metacompetence']).code_clea_sous_sous_domaine
          end
          tri_par_ordre_croissant(sous_groupes_clea)
        end
      end

      def questions_repondues_et_non_repondues
        non_repondues = questions_non_repondues.map(&:as_json).each do |q|
          q['scoreMax'] = q.delete('score')
          q['question'] = q.delete('nom_technique')
        end
        @evenements_reponses.map(&:donnees) + non_repondues
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

      def tri_par_ordre_croissant(groupes_clea)
        groupes_clea.sort_by { |code, _| code.to_s }.to_h
      end

      def question_rattrapage(nom_technique)
        nom_technique.start_with?('N1R', 'N2R', 'N3R')
      end

      # On vérifie si l'évalué a répondu à une question de rattrapage
      def a_repondu_a_une_question_rattrapage?(reponses)
        reponses.any? do |e|
          question_rattrapage(e['question']) && e['score'].present?
        end
      end

      # On filtre les réponses pour ne garder ou non les questions de rattrapage
      # Si il a répondu à une question de rattrapage, on garde toutes les réponses rattrapage
      def reponses_filtres(reponses)
        return reponses if a_repondu_a_une_question_rattrapage?(reponses)

        reponses.reject { |e| question_rattrapage(e['question']) }
      end

      def pourcentage_reussite(reponses)
        scores = reponses.map { |e| [e['scoreMax'] || 0, e['score'] || 0] }
        score_max, score = scores.transpose.map(&:sum)
        pourcentage = Pourcentage.new(valeur: score, valeur_max: score_max).calcul&.round
        score_max.zero? ? 'non applicable' : "#{pourcentage}%"
      end
    end
  end
end
