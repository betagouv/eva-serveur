# frozen_string_literal: true

module ImportExport
  module Questions
    class Export < ::ImportExport::ExportXls
      include Fichier

      def initialize(questions, headers)
        super()
        @donnees = questions
        @headers = headers
      end

      private

      def remplis_champs(question)
        col = -1
        @onglet.set_valeur(@ligne, col += 1, question.libelle)
        @onglet.set_valeur(@ligne, col += 1, question.nom_technique)
        @onglet.set_valeur(@ligne, col += 1, question.illustration_url(variant: nil))
        @onglet.set_valeur(@ligne, col += 1, question.transcription_intitule&.ecrit)
        @onglet.set_valeur(@ligne, col += 1, question.transcription_intitule&.audio_url)
        col
      end
    end
  end
end
