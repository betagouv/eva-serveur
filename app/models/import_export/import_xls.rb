# frozen_string_literal: true

module ImportExport
  class ImportXls
    class Error < StandardError; end

    def initialize(type, headers)
      @type = type
      @headers_attendus = headers
    end

    def valide_headers
      return if headers_valides?

      raise Error, message_erreur_headers
    end

    def message_erreur_headers
      I18n.t('.layouts.erreurs.import_question.mauvais_format',
             headers: headers_attendus_to_s)
    end

    def headers_valides?
      headers_serialises = @headers.map do |header|
        header.parameterize.underscore.to_sym if header
      end
      headers_serialises[0, @headers_attendus.length] == @headers_attendus
    end

    def headers_attendus_to_s
      @headers_attendus.map do |h|
        h.to_s.tr('_', ' ')
      end.join(', ')
    end

    def recupere_data(file)
      sheet = Spreadsheet.open(file.path).worksheet(0)
      @data = sheet.rows[1]
      @headers = sheet.rows[0]
    end

    def telecharge_fichier(url)
      @current_download = url
      return unless url

      fichier = Down.download(url)
      content_type = Marcel::MimeType.for(fichier.path, name: fichier.original_filename)

      { io: fichier,
        filename: fichier.original_filename,
        content_type: content_type }
    rescue Down::Error
      raise Error, message_erreur_telechargement(@current_download)
    end

    def message_erreur_telechargement(current_download)
      "Impossible de télécharger un fichier depuis l'url : #{current_download}"
    end

    def attache_fichier(attachment, url)
      attachment.attach(telecharge_fichier(url)) if url.present?
    end
  end
end
