# frozen_string_literal: true

module ImportExport
  module Questions
    class Export < ::ImportExport::ExportXls
      def initialize(questions, headers)
        super()
        @questions = questions
        @headers = headers
      end

      def to_xls
        entetes = @headers.map { |header| { titre: header.to_s.humanize, taille: 20 } }
        @export = ::ImportExport::ExportXls.new
        @onglet = @export.cree_worksheet_donnees(entetes)

        remplis_la_feuille
        retourne_le_contenu_du_xls
      end

      def nom_du_fichier(type)
        genere_fichier(type)
      end

      private

      def remplis_la_feuille
        @questions.each_with_index do |question, index|
          @question = question
          @ligne = index + 1
          remplis_champs_commun
        end
      end

      def remplis_champs_commun
        @onglet.set_valeur(@ligne, 0, @question.libelle)
        @onglet.set_valeur(@ligne, 1, @question.nom_technique)
        @onglet.set_valeur(@ligne, 2, @question.illustration_url)
        @onglet.set_valeur(@ligne, 3, @question.transcription_intitule&.ecrit)
        @onglet.set_valeur(@ligne, 4, @question.transcription_intitule&.audio_url)
        remplis_champs_additionnels
      end

      def remplis_champs_additionnels
        return if @question.sous_consigne?

        @onglet.set_valeur(@ligne, 5, @question.transcription_modalite_reponse&.ecrit)
        @onglet.set_valeur(@ligne, 6, @question.transcription_modalite_reponse&.audio_url)
        @onglet.set_valeur(@ligne, 7, @question.description)
        remplis_champs_specifiques
      end

      def remplis_champs_specifiques
        case @question.type
        when QuestionClicDansImage::QUESTION_TYPE then remplis_champs_clic_dans_image
        when QuestionGlisserDeposer::QUESTION_TYPE then remplis_champs_glisser_deposer
        when QuestionQcm::QUESTION_TYPE then remplis_champs_qcm
        when QuestionSaisie::QUESTION_TYPE then remplis_champs_saisie
        when QuestionClicDansTexte::QUESTION_TYPE then remplis_champs_clic_dans_texte
        end
      end

      def remplis_champs_clic_dans_image
        @onglet.set_valeur(@ligne, 8, @question.zone_cliquable_url)
        @onglet.set_valeur(@ligne, 9, @question.image_au_clic_url)
      end

      def remplis_champs_glisser_deposer
        @onglet.set_valeur(@ligne, 8, @question.zone_depot_url)
        @onglet.set_valeur(@ligne, 9, @question.orientation)
        @question.reponses.each_with_index { |choix, index| ajoute_reponses(choix, index) }
      end

      def remplis_champs_saisie
        @onglet.set_valeur(@ligne, 8, @question.suffix_reponse)
        @onglet.set_valeur(@ligne, 9, @question.reponse_placeholder)
        @onglet.set_valeur(@ligne, 10, @question.type_saisie)
        @onglet.set_valeur(@ligne, 11, @question.texte_a_trous)
        @question.reponses.each_with_index { |reponse, index| ajoute_saisies(reponse, index) }
      end

      def remplis_champs_qcm
        @onglet.set_valeur(@ligne, 8, @question.type_qcm)
        @question.choix.each_with_index { |choix, index| ajoute_choix(choix, index) }
      end

      def remplis_champs_clic_dans_texte
        @onglet.set_valeur(@ligne, 8, @question.texte_sur_illustration)
      end

      def ajoute_choix(choix, index)
        columns = %w[intitule nom_technique type_choix audio_url]
        columns.each_with_index do |col, i|
          colonne = 9 + (index * columns.size) + i
          @onglet.set_valeur(0, colonne, "choix_#{index + 1}_#{col}")
          @onglet.set_valeur(@ligne, colonne, choix.send(col))
        end
      end

      def ajoute_saisies(reponse, index)
        columns = %w[intitule nom_technique type_choix]
        columns.each_with_index do |col, i|
          colonne = 12 + (index * columns.size) + i
          @onglet.set_valeur(0, colonne, "reponse_#{index + 1}_#{col}")
          @onglet.set_valeur(@ligne, colonne, reponse.send(col))
        end
      end

      def ajoute_reponses(choix, index)
        columns = %w[nom_technique position_client type_choix illustration_url]
        columns.each_with_index do |col, i|
          colonne = 10 + (index * columns.size) + i
          @onglet.set_valeur(0, colonne, "reponse_#{index + 1}_#{col}")
          @onglet.set_valeur(@ligne, colonne, choix.send(col).to_s)
        end
      end
    end
  end
end
