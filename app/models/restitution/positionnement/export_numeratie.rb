# frozen_string_literal: true

module Restitution
  module Positionnement
    class ExportNumeratie # rubocop:disable Metrics/ClassLength
      def initialize(partie, onglet_xls)
        @onglet_xls = onglet_xls

        @temps_par_question = Restitution::Metriques::TempsPasseParQuestion
                              .new(partie.evenements).calculer

        @evenements_questions = evenements_questions(partie)
        @evenements_questions_a_prendre_en_compte =
          EvenementQuestion.prises_en_compte_pour_calcul_score_clea(@evenements_questions)
      end

      def evenements_questions(partie)
        evenements_reponses = Evenement.where(session_id: partie.session_id).reponses
        questions_situation = partie.campagne.questionnaire_pour(partie.situation).questions
        questions_situation_repondables = questions_situation.to_a.reject do |question|
          question.type == QuestionSousConsigne::QUESTION_TYPE
        end
        questions_situation_repondables.map do |question|
          reponse = reponse_de_la_question(evenements_reponses, question.nom_technique)
          EvenementQuestion.new(question: question, evenement: reponse)
        end
      end

      def reponse_de_la_question(evenements_reponses, nom_technique)
        evenements_reponses.find { |e| e.question_nom_technique == nom_technique }
      end

      def remplis_reponses(ligne)
        regroupe_par_codes_clea.each_value do |sous_codes|
          ligne = remplis_par_sous_domaine(ligne, sous_codes)
        end
      end

      def remplis_par_sous_domaine(ligne, sous_codes)
        sous_codes.each_value do |evenements_questions|
          ligne = remplis_reponses_sous_sous_domaine(ligne, evenements_questions)
        end
        ligne
      end

      def regroupe_par_codes_clea
        groupes_clea = regroupe_par_sous_domaine
        regroupe_par_sous_sous_domaine(groupes_clea)
      end

      def remplis_sous_domaine(ligne, code, evenements_questions)
        @onglet_xls.set_valeur(ligne, 0, code)
        valeurs_communes(ligne, code, evenements_questions)
      end

      def remplis_sous_sous_domaine(ligne, sous_code, evenements_questions)
        @onglet_xls.set_valeur(ligne, 0, sous_code)
        valeurs_communes(ligne, sous_code, evenements_questions)
      end

      def remplis_reponses_sous_sous_domaine(ligne, evenements_questions)
        evenements_questions.each do |evenement_question|
          ligne = remplis_ligne(ligne, evenement_question)
        end
        ligne
      end

      private

      def valeurs_communes(ligne, code, evenements_questions)
        evenements_questions = EvenementQuestion.filtre_pris_en_compte(
          evenements_questions, @evenements_questions_a_prendre_en_compte
        )

        @onglet_xls.set_valeur(ligne, 1, intitule_code_clea(code))
        @onglet_xls.set_nombre(ligne, 2, EvenementQuestion.score_pour_groupe(evenements_questions))
        @onglet_xls.set_nombre(ligne, 3,
                               EvenementQuestion.score_max_pour_groupe(evenements_questions))
        @onglet_xls.set_pourcentage(ligne, 4, pourcentage(evenements_questions))
      end

      def regroupe_par_sous_domaine
        groupes_clea = @evenements_questions.group_by do |evenement_question|
          Metacompetence.new(evenement_question.metacompetence).code_clea_sous_domaine
        end
        tri_par_ordre_croissant(groupes_clea)
      end

      def regroupe_par_sous_sous_domaine(groupes_clea)
        groupes_clea.transform_values do |groupes|
          sous_groupes_clea = groupes.group_by do |evenement_question|
            Metacompetence.new(evenement_question.metacompetence).code_clea_sous_sous_domaine
          end
          tri_par_ordre_croissant(sous_groupes_clea)
        end
      end

      def remplis_ligne(ligne, evenement_question) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        @onglet_xls.grise_ligne(ligne) unless evenement_question.a_ete_repondue?

        @onglet_xls.set_valeur(ligne, 0, evenement_question.code_clea)
        @onglet_xls.set_valeur(ligne, 1, evenement_question.nom_technique)
        @onglet_xls.set_valeur(ligne, 2, evenement_question.metacompetence&.humanize)
        @onglet_xls.set_nombre(ligne, 3, evenement_question.score)
        @onglet_xls.set_nombre(ligne, 4, evenement_question.score_max)
        pris_en_compte = pris_en_compte_pour_calcul_score_clea?(evenement_question)
        @onglet_xls.set_valeur(ligne, 5, pris_en_compte)
        @onglet_xls.set_valeur(ligne, 6, evenement_question.interaction)
        @onglet_xls.set_valeur(ligne, 7, evenement_question.intitule)

        remplis_choix(ligne, evenement_question)
        ligne + 1
      end

      def pris_en_compte_pour_calcul_score_clea?(evenement_question)
        pris_en_compte =
          evenement_question.pris_en_compte_pour_calcul_score_clea?(
            @evenements_questions_a_prendre_en_compte
          )
        pris_en_compte ? 'Oui' : 'Non'
      end

      def remplis_choix(ligne, evenement_question)
        @onglet_xls.set_valeur(ligne, 8, evenement_question.reponses_possibles)
        @onglet_xls.set_valeur(ligne, 9, evenement_question.reponses_attendues)
        @onglet_xls.set_valeur(ligne, 10, evenement_question.reponse)
        @onglet_xls.set_valeur(ligne, 11, @temps_par_question[evenement_question.nom_technique])
      end

      # Trie par code cléa et par question
      def tri_par_ordre_croissant(groupes_clea)
        groupes_clea.sort_by do |code, evenements_questions|
          [code.to_s, evenements_questions.map(&:nom_technique).sort]
        end.to_h
      end

      def pourcentage(evenements_questions)
        pourcentage = EvenementQuestion.pourcentage_pour_groupe(evenements_questions)
        return 'non applicable' if pourcentage.nil?

        pourcentage.to_f / 100
      end

      def intitule_code_clea(code)
        Metacompetence::CODECLEA_INTITULES[code]
      end
    end
  end
end
