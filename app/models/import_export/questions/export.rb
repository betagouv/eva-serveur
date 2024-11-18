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
        @sheet = ::ImportExport::ExportXls.new(entetes: entetes).sheet
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
        @sheet[@ligne, 0] = @question.libelle
        @sheet[@ligne, 1] = @question.nom_technique
        @sheet[@ligne, 2] = @question.illustration_url
        @sheet[@ligne, 3] = @question.transcription_intitule&.ecrit
        @sheet[@ligne, 4] = @question.transcription_intitule&.audio_url
        remplis_champs_additionnels
      end

      def remplis_champs_additionnels
        return if @question.sous_consigne?

        @sheet[@ligne, 6] = @question.transcription_modalite_reponse&.audio_url
        @sheet[@ligne, 5] = @question.transcription_modalite_reponse&.ecrit
        @sheet[@ligne, 7] = @question.description
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
        @sheet[@ligne, 8] = @question.zone_cliquable_url
        @sheet[@ligne, 9] = @question.image_au_clic_url
      end

      def remplis_champs_glisser_deposer
        @sheet[@ligne, 8] = @question.zone_depot_url
        @question.reponses.each_with_index { |choix, index| ajoute_reponses(choix, index) }
      end

      def remplis_champs_saisie
        @sheet[@ligne, 8] = @question.suffix_reponse
        @sheet[@ligne, 9] = @question.reponse_placeholder
        @sheet[@ligne, 10] = @question.type_saisie
        @question.reponses.each_with_index { |reponse, index| ajoute_saisies(reponse, index) }
      end

      def remplis_champs_qcm
        @sheet[@ligne, 8] = @question.type_qcm
        @question.choix.each_with_index { |choix, index| ajoute_choix(choix, index) }
      end

      def remplis_champs_clic_dans_texte
        @sheet[@ligne, 8] = @question.texte_sur_illustration
      end

      def ajoute_choix(choix, index)
        columns = %w[intitule nom_technique type_choix audio]
        columns.each_with_index do |col, i|
          @sheet[0, 9 + (index * 4) + i] = "choix_#{index + 1}_#{col}"
          @sheet[@ligne, 9 + (index * 4) + i] = choix.send(col)
        end
      end

      def ajoute_saisies(reponse, index)
        columns = %w[intitule nom_technique type_choix]
        columns.each_with_index do |col, i|
          @sheet[0, 11 + (index * 3) + i] = "reponse_#{index + 1}_#{col}"
          @sheet[@ligne, 11 + (index * 3) + i] = reponse.send(col)
        end
      end

      def ajoute_reponses(choix, index)
        columns = %w[nom_technique position_client type_choix illustration]
        columns.each_with_index do |col, i|
          @sheet[0, 9 + (index * 4) + i] = "reponse_#{index + 1}_#{col}"
          @sheet[@ligne, 9 + (index * 4) + i] = choix.send(col)
        end
      end
    end
  end
end
