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
          remplis_champs
        end
      end

      def remplis_champs
        col = -1
        @onglet.set_valeur(@ligne, col += 1, @question.libelle)
        @onglet.set_valeur(@ligne, col += 1, @question.nom_technique)
        @onglet.set_valeur(@ligne, col += 1, @question.illustration_url(variant: nil))
        @onglet.set_valeur(@ligne, col += 1, @question.transcription_intitule&.ecrit)
        @onglet.set_valeur(@ligne, col += 1, @question.transcription_intitule&.audio_url)
        col
      end
    end
  end
end
