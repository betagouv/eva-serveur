# frozen_string_literal: true

module ImportExport
  module Questions
    class ImportExportDonnees
      HEADERS_CLIC_DANS_IMAGE = %i[zone_cliquable image_au_clic].freeze
      HEADERS_CLIC_DANS_TEXTE = %i[texte_sur_illustration].freeze
      HEADERS_GLISSER_DEPOSER = %i[zone_depot orientation].freeze
      HEADERS_QCM = %i[type_qcm].freeze
      HEADERS_SAISIE = %i[suffix_reponse reponse_placeholder type_saisie texte_a_trous].freeze
      HEADERS_COMMUN = %i[libelle nom_technique illustration intitule_ecrit intitule_audio].freeze
      HEADERS_QUESTION_TEST = %i[metacompetence consigne_ecrit consigne_audio description
                                 demarrage_audio_modalite_reponse].freeze
      HEADERS_ATTENDUS = {
        QuestionClicDansImage::QUESTION_TYPE =>
          HEADERS_COMMUN + HEADERS_QUESTION_TEST + HEADERS_CLIC_DANS_IMAGE,
        QuestionClicDansTexte::QUESTION_TYPE =>
          HEADERS_COMMUN + HEADERS_QUESTION_TEST + HEADERS_CLIC_DANS_TEXTE,
        QuestionGlisserDeposer::QUESTION_TYPE =>
          HEADERS_COMMUN + HEADERS_QUESTION_TEST + HEADERS_GLISSER_DEPOSER,
        QuestionQcm::QUESTION_TYPE => HEADERS_COMMUN + HEADERS_QUESTION_TEST + HEADERS_QCM,
        QuestionSaisie::QUESTION_TYPE => HEADERS_COMMUN + HEADERS_QUESTION_TEST + HEADERS_SAISIE,
        QuestionSousConsigne::QUESTION_TYPE => HEADERS_COMMUN
      }.freeze
      IMPORTEURS = {
        QuestionClicDansImage::QUESTION_TYPE => Import::QuestionClicDansImage,
        QuestionClicDansTexte::QUESTION_TYPE => Import::QuestionClicDansTexte,
        QuestionGlisserDeposer::QUESTION_TYPE => Import::QuestionGlisserDeposer,
        QuestionQcm::QUESTION_TYPE => Import::QuestionQcm,
        QuestionSaisie::QUESTION_TYPE => Import::QuestionSaisie,
        QuestionSousConsigne::QUESTION_TYPE => Import::QuestionSousConsigne
      }.freeze
      EXPORTEURS = {
        QuestionClicDansImage::QUESTION_TYPE => Export::QuestionClicDansImage,
        QuestionClicDansTexte::QUESTION_TYPE => Export::QuestionClicDansTexte,
        QuestionGlisserDeposer::QUESTION_TYPE => Export::QuestionGlisserDeposer,
        QuestionQcm::QUESTION_TYPE => Export::QuestionQcm,
        QuestionSaisie::QUESTION_TYPE => Export::QuestionSaisie,
        QuestionSousConsigne::QUESTION_TYPE => Export::QuestionSousConsigne
      }.freeze

      def initialize(questions: nil, type: nil)
        @questions = questions
        @type = type
      end

      def importe_donnees(file)
        IMPORTEURS[@type].new(HEADERS_ATTENDUS[@type]).import_from_xls(file)
      rescue ActiveRecord::RecordInvalid => e
        raise Import::Error, e.record.errors.full_messages.to_sentence
      end

      def exporte_donnees
        export = EXPORTEURS[@type].new(@questions, HEADERS_ATTENDUS[@type])
        {
          xls: export.to_xls,
          content_type: export.content_type_xls,
          filename: export.nom_du_fichier(@type)
        }
      end
    end
  end
end
