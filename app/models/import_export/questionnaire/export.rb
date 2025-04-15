# frozen_string_literal: true

module ImportExport
  module Questionnaire
    class Export < ::ImportExport::ExportXls
      include Fichier

      def initialize(questionnaires, headers)
        super()
        @questionnaires = Array(questionnaires)
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
        nom_fichier_horodate(type, 'xls')
      end

      private

      def remplis_la_feuille
        @questionnaires.each_with_index do |questionnaire, index|
          @ligne = index + 1
          @questionnaire = questionnaire
          remplis_champs
        end
      end

      def remplis_champs
        col = -1
        @onglet.set_valeur(@ligne, col += 1, @questionnaire.libelle)
        @onglet.set_valeur(@ligne, col += 1, @questionnaire.nom_technique)
        @onglet.set_valeur(@ligne, col += 1,
                           @questionnaire.questions.map(&:nom_technique).join(','))
        col
      end
    end
  end
end
