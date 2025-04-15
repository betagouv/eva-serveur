# frozen_string_literal: true

module ImportExport
  module Questionnaire
    class ImportExportDonnees
      HEADERS_ATTENDUS = %i[libelle nom_technique questions].freeze

      def initialize(questionnaires:)
        @questionnaires = Array(questionnaires)
      end

      def exporte_donnees
        export = Export.new(@questionnaires, HEADERS_ATTENDUS)
        {
          xls: export.to_xls,
          content_type: export.content_type_xls,
          filename: export.nom_du_fichier(@type)
        }
      end
    end
  end
end
