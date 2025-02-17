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
      @headers = sheet.rows[0] # La première ligne contient les headers
      @data = sheet.rows[1..] # Les autres lignes contiennent les données
    end

    def attache_fichier(attachment, url, nom_technique)
      attachment.attach(ImportXls.telecharge_fichier(url, nom_technique)) if url.present?
    end

    XLS_MIME_TYPE = 'application/vnd.ms-excel'

    def self.fichier_xls?(file)
      file.content_type == XLS_MIME_TYPE && File.extname(file.original_filename) == '.xls'
    end

    def self.telecharge_fichier(url, nom_technique)
      fichier = Down.download(url)
      extension = File.extname(url)
      nom_fichier = "#{nom_technique}#{extension}"
      content_type = Marcel::MimeType.for extension: extension
      { io: fichier, filename: nom_fichier, content_type: content_type }
    rescue Down::Error
      raise Error, I18n.t('.layouts.erreurs.import_question.telechargement_impossible', url: url)
    end
  end
end
