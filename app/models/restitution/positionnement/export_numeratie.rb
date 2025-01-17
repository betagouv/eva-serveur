# frozen_string_literal: true

module Restitution
  module Positionnement
    class ExportNumeratie # rubocop:disable Metrics/ClassLength
      def initialize(partie, sheet)
        @partie = partie
        @evenements_reponses = Evenement.where(session_id: @partie.session_id).reponses
        @sheet = sheet
        @temps_par_question = Restitution::Metriques::TempsPasseParQuestion
                              .new(@partie.evenements).calculer
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
        pourcentage = pourcentage_reussite(filtre_evenements_reponses(reponses))
        score_max = calcule_score_max(filtre_evenements_reponses(reponses))
        score = calcule_score(filtre_evenements_reponses(reponses))
        intitule_code_cle = Metacompetence::CODECLEA_INTITULES[code]

        @sheet[ligne, 0] = code
        @sheet[ligne, 1] = intitule_code_cle
        @sheet[ligne, 2] = score
        @sheet[ligne, 3] = score_max
        @sheet[ligne, 4] = pourcentage
      end

      def remplis_sous_sous_domaine(ligne, sous_code, reponses)
        pourcentage = pourcentage_reussite(filtre_evenements_reponses(reponses))
        score_max = calcule_score_max(filtre_evenements_reponses(reponses))
        score = calcule_score(filtre_evenements_reponses(reponses))
        intitule_code_cle = Metacompetence::CODECLEA_INTITULES[sous_code]

        @sheet[ligne, 0] = sous_code
        @sheet[ligne, 1] = intitule_code_cle
        @sheet[ligne, 2] = score
        @sheet[ligne, 3] = score_max
        @sheet[ligne, 4] = pourcentage
      end

      def remplis_reponses(ligne, reponses)
        liste_questions = filtre_evenements_reponses(reponses).map { |e| [e['question']] }.flatten

        reponses.each do |reponse|
          question = Question.find_by(nom_technique: reponse['question'])
          ligne = remplis_ligne(ligne, reponse, question, liste_questions)
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

      def remplis_ligne(ligne, donnees, question, liste_questions)
        est_non_repondu = questions_non_repondues.any? do |q|
          q[:nom_technique] == donnees['question']
        end

        code = Metacompetence.new(donnees['metacompetence']).code_clea_sous_sous_domaine
        row_data = ligne_data(code, donnees, question, liste_questions)
        @sheet.row(ligne).replace(row_data)
        grise_ligne(ligne) if est_non_repondu
        remplis_choix(ligne, donnees, question)
        ligne + 1
      end

      XLS_COLOR_GRAY = :xls_color_14 # rubocop:disable Naming/VariableNumber
      def grise_ligne(ligne)
        format_grise = Spreadsheet::Format.new(pattern_fg_color: XLS_COLOR_GRAY, pattern: 1)
        @sheet.row(ligne).default_format = format_grise
      end

      def ligne_data(code, donnees, question, liste_questions)
        [
          code,
          donnees['question'],
          donnees['metacompetence']&.humanize,
          donnees['score'].to_s,
          donnees['scoreMax'].to_s,
          pris_en_compte_pour_calcul_score_clea?(liste_questions, donnees['question']),
          question&.interaction,
          donnees['intitule']
        ]
      end

      def pris_en_compte_pour_calcul_score_clea?(liste_questions, question)
        liste_questions.include?(question) ? 'Oui' : 'Non'
      end

      def remplis_choix(ligne, donnees, question)
        @sheet[ligne, 8] = question&.interaction == 'qcm' ? question&.liste_choix : nil
        @sheet[ligne, 9] = question&.bonnes_reponses if question&.qcm? || question&.saisie?
        @sheet[ligne, 10] = donnees['reponseIntitule'] || donnees['reponse']
        @sheet[ligne, 11] = @temps_par_question[donnees['question']]
      end

      # Trie par code cléa et par question
      def tri_par_ordre_croissant(groupes_clea)
        groupes_clea.sort_by do |code, reponses|
          [code.to_s, reponses.pluck('question').sort]
        end.to_h
      end

      def filtre_evenements_reponses(evenements)
        evenements = evenements_par_module(evenements, :N1)
        evenements = evenements_par_module(evenements, :N2)
        evenements_par_module(evenements, :N3)
      end

      def evenements_par_module(evenements, nom_module)
        module_rattrapage = "#{nom_module}R"
        a_fait_un_rattrapage = evenements.any? do |e|
          e['question'].start_with?(module_rattrapage) && e['score'].present?
        end
        return evenements if a_fait_un_rattrapage

        evenements.reject { |e| e['question'].start_with?(module_rattrapage) }
      end

      def pourcentage_reussite(reponses)
        scores = reponses.map { |e| [e['scoreMax'] || 0, e['score'] || 0] }
        score_max, score = scores.transpose.map(&:sum)
        pourcentage = Pourcentage.new(valeur: score, valeur_max: score_max).calcul&.round
        score_max.zero? ? 'non applicable' : "#{pourcentage}%"
      end

      def calcule_score_max(reponses)
        reponses.map { |e| e['scoreMax'] || 0 }.sum
      end

      def calcule_score(reponses)
        reponses.map { |e| e['score'] || 0 }.sum
      end
    end
  end
end
