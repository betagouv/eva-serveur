# frozen_string_literal: true

module ImportExport
  module Questions
    class ImportExportDonnees
      HEADERS_CLIC_DANS_IMAGE = %i[zone_cliquable image_au_clic].freeze
      HEADERS_CLIC_DANS_TEXTE = %i[texte_sur_illustration].freeze
      HEADERS_GLISSER_DEPOSER = %i[zone_depot].freeze
      HEADERS_QCM = %i[type_qcm].freeze
      HEADERS_SAISIE = %i[suffix_reponse reponse_placeholder type_saisie texte_a_trous].freeze
      HEADERS_SOUS_CONSIGNE = %i[libelle nom_technique illustration intitule_ecrit
                                 intitule_audio].freeze
      HEADERS_COMMUN = %i[libelle nom_technique illustration intitule_ecrit intitule_audio
                          consigne_ecrit consigne_audio description].freeze
      HEADERS_ATTENDUS = {
        QuestionClicDansImage::QUESTION_TYPE => HEADERS_COMMUN + HEADERS_CLIC_DANS_IMAGE,
        QuestionClicDansTexte::QUESTION_TYPE => HEADERS_COMMUN + HEADERS_CLIC_DANS_TEXTE,
        QuestionGlisserDeposer::QUESTION_TYPE => HEADERS_COMMUN + HEADERS_GLISSER_DEPOSER,
        QuestionQcm::QUESTION_TYPE => HEADERS_COMMUN + HEADERS_QCM,
        QuestionSaisie::QUESTION_TYPE => HEADERS_COMMUN + HEADERS_SAISIE,
        QuestionSousConsigne::QUESTION_TYPE => HEADERS_SOUS_CONSIGNE
      }.freeze

      def initialize(questions: nil, type: nil)
        @questions = questions
        @type = type
      end

      def importe_donnees(file)
        Import.new(@type, HEADERS_ATTENDUS[@type]).import_from_xls(file)
      rescue ActiveRecord::RecordInvalid => e
        raise Import::Error, message_erreur_validation(e)
      end

      def exporte_donnees
        export = Export.new(@questions, HEADERS_ATTENDUS[@type])
        {
          xls: export.to_xls,
          content_type: export.content_type_xls,
          filename: export.nom_du_fichier(@type)
        }
      end

      def message_erreur_validation(exception, row)
        "Erreur ligne #{row}: #{exception.record.errors.full_messages.to_sentence}"
      end
    end
  end
end
