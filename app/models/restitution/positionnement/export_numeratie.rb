# frozen_string_literal: true

module Restitution
  module Positionnement
    class ExportNumeratie # rubocop:disable Metrics/ClassLength
      def initialize(partie, onglet_xls)
        super()
        @partie = partie
        @evenements_reponses = Evenement.where(session_id: @partie.session_id).reponses
        @onglet_xls = onglet_xls
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
        @onglet_xls.set_valeur(ligne, 0, code)
        valeurs_communes(ligne, code, reponses)
      end

      def remplis_sous_sous_domaine(ligne, sous_code, reponses)
        @onglet_xls.set_valeur(ligne, 0, sous_code)
        valeurs_communes(ligne, sous_code, reponses)
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

      def valeurs_communes(ligne, code, reponses)
        @onglet_xls.set_valeur(ligne, 1, intitule_code_clea(code))
        @onglet_xls.set_nombre(ligne, 2, score(reponses))
        @onglet_xls.set_nombre(ligne, 3, score_max(reponses))
        @onglet_xls.set_pourcentage(ligne, 4, pourcentage(reponses))
      end

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

      def remplis_ligne(ligne, donnees, question, liste_questions) # rubocop:disable Metrics
        est_non_repondu = questions_non_repondues.any? do |q|
          q[:nom_technique] == donnees['question']
        end

        code = Metacompetence.new(donnees['metacompetence']).code_clea_sous_sous_domaine
        @onglet_xls.set_valeur(ligne, 0, code)
        @onglet_xls.set_valeur(ligne, 1, donnees['question'])
        @onglet_xls.set_valeur(ligne, 2, donnees['metacompetence']&.humanize)
        @onglet_xls.set_valeur(ligne, 3, donnees['score'])
        @onglet_xls.set_valeur(ligne, 4, donnees['scoreMax'])
        valeur = pris_en_compte_pour_calcul_score_clea?(liste_questions, donnees['question'])
        @onglet_xls.set_valeur(ligne, 5, valeur)
        @onglet_xls.set_valeur(ligne, 6, question&.interaction)
        @onglet_xls.set_valeur(ligne, 7, donnees['intitule'])

        @onglet_xls.grise_ligne(ligne) if est_non_repondu
        remplis_choix(ligne, donnees, question)
        ligne + 1
      end

      def pris_en_compte_pour_calcul_score_clea?(liste_questions, question)
        liste_questions.include?(question) ? 'Oui' : 'Non'
      end

      def remplis_choix(ligne, donnees, question)
        choix = question&.interaction == 'qcm' ? question&.liste_choix : nil
        @onglet_xls.set_valeur(ligne, 8, choix)
        if question&.qcm? || question&.saisie?
          @onglet_xls.set_valeur(ligne, 9, question&.bonnes_reponses)
        end
        reponse = donnees['reponseIntitule'] || donnees['reponse']
        @onglet_xls.set_valeur(ligne, 10, reponse)
        @onglet_xls.set_valeur(ligne, 11, @temps_par_question[donnees['question']])
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
        return 'non applicable' if pourcentage.nil?

        pourcentage.to_f / 100
      end

      def calcule_score_max(reponses)
        reponses.map { |e| e['scoreMax'] || 0 }.sum
      end

      def calcule_score(reponses)
        reponses.map { |e| e['score'] || 0 }.sum
      end

      def pourcentage(reponses)
        pourcentage_reussite(filtre_evenements_reponses(reponses))
      end

      def score_max(reponses)
        calcule_score_max(filtre_evenements_reponses(reponses))
      end

      def score(reponses)
        calcule_score(filtre_evenements_reponses(reponses))
      end

      def intitule_code_clea(code)
        Metacompetence::CODECLEA_INTITULES[code]
      end
    end
  end
end
