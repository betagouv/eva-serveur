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
          Metacompetence.code_clea_sous_domaine(evenement_question.metacompetence)
        end
        tri_par_ordre_croissant(groupes_clea)
      end

      def regroupe_par_sous_sous_domaine(groupes_clea)
        groupes_clea.transform_values do |groupes|
          sous_groupes_clea = groupes.group_by do |evenement_question|
            Metacompetence.code_clea_sous_sous_domaine(evenement_question.metacompetence)
          end
          tri_par_ordre_croissant(sous_groupes_clea)
        end
      end

      def remplis_ligne(ligne, evenement_question) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        @onglet_xls.set_valeur(ligne, 0, evenement_question.code_clea)
        @onglet_xls.set_valeur(ligne, 1, evenement_question.nom_technique)
        @onglet_xls.set_valeur(ligne, 2, evenement_question.metacompetence&.humanize)
        @onglet_xls.set_valeur_booleenne(ligne, 3, evenement_question.a_ete_repondue?)
        @onglet_xls.set_nombre(ligne, 4, evenement_question.score)
        @onglet_xls.set_nombre(ligne, 5, evenement_question.score_max)
        pris_en_compte = pris_en_compte_pour_calcul_score_clea?(evenement_question)
        @onglet_xls.set_valeur(ligne, 6, pris_en_compte)
        @onglet_xls.set_valeur(ligne, 7, I18n.t(".interaction.#{evenement_question.type_question}"))
        @onglet_xls.set_valeur(ligne, 8, evenement_question.intitule)

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
        @onglet_xls.set_valeur(ligne, 9, evenement_question.reponses_possibles)
        @onglet_xls.set_valeur(ligne, 10, evenement_question.bonnes_reponses)
        @onglet_xls.set_valeur(ligne, 11, evenement_question.reponse)
        @onglet_xls.set_valeur(ligne, 12, @temps_par_question[evenement_question.nom_technique])
      end

      def tri_par_ordre_croissant(groupes_clea)
        groupes_clea = groupes_clea.sort_by { |code, _| code.to_s }.to_h
        tri_par_metacompetence(groupes_clea)
      end

      def tri_par_metacompetence(groupes_clea)
        groupes_clea.transform_values do |evenements_questions|
          groupes_familles = regroupe_par_famille(evenements_questions)
          trie_les_familles(groupes_familles)
        end
      end

      def pourcentage(evenements_questions)
        pourcentage = EvenementQuestion.pourcentage_pour_groupe(evenements_questions)
        return 'non applicable' if pourcentage.nil?

        pourcentage.to_f / 100
      end

      def intitule_code_clea(code)
        Metacompetence::CODECLEA_INTITULES[code]
      end

      def regroupe_par_famille(evenements_questions)
        evenements_questions.group_by do |eq|
          nom = eq.nom_technique
          match = nom.match(/(N\d+)([PR])([a-z]+)(\d+)/)
          next nom unless match

          prefixe = match[1]
          categorie = match[3]
          "#{prefixe}#{categorie}"
        end
      end

      def trie_les_familles(groupes_familles)
        groupes_familles.sort_by { |famille, _| famille }.flat_map do |_, questions|
          trie_les_questions(questions)
        end
      end

      def trie_les_questions(questions)
        questions.sort_by do |eq|
          nom = eq.nom_technique
          match = nom.match(/(N\d+)([PR])([a-z]+)(\d+)/)
          next nom unless match

          type = match[2]
          numero = match[4].to_i

          [type == 'P' ? 0 : 1, numero]
        end
      end
    end
  end
end
