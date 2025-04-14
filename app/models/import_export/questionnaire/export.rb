# frozen_string_literal: true

module ImportExport
  module Questionnaire
    class Export < ::ImportExport::ExportXls
      include Fichier

      def initialize(questionnaires, headers)
        super()
        @donnees = Array(questionnaires)
        @headers = headers
      end

      private

      def remplis_champs(questionnaire)
        col = -1
        @onglet.set_valeur(@ligne, col += 1, questionnaire.libelle)
        @onglet.set_valeur(@ligne, col += 1, questionnaire.nom_technique)
        @onglet.set_valeur(@ligne, col += 1,
                           questionnaire.questions.map(&:nom_technique).join(","))
        col
      end
    end
  end
end
