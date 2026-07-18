module Admin
  module Evaluations
    class XlsConfiguration
      def appliquer_limite!(sheet:, collection:)
        limite = ImportExport::ExportXls::NOMBRE_MAX_LIGNES
        return collection unless collection.count > limite

        sheet << [ I18n.t("active_admin.export.limite_atteinte", limite: limite) ]
        collection.limit!(limite)
      end
    end
  end
end
