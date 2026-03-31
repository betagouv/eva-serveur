module Admin
  module Evaluations
    class XlsConfiguration
      COLONNES_COMMUNES = %i[structure campagne debutee_le completude].freeze
      COLONNES_EVA_PRO = %i[
        par
        taux_risque
        performance_collective
        agilite_organisationnelle
        securite_qualite
        mobilite_professionnelle
        score_cout
        bilan_situation
      ].freeze
      COLONNES_HORS_EVA_PRO = %i[
        nom_beneficiaire
        code_beneficiaire
        synthese_competences_de_base
        niveau_cefr
        niveau_cnef
        niveau_anlci_litteratie
        niveau_anlci_numeratie
        positionnement_niveau_litteratie
        positionnement_niveau_numeratie
        reponses_redaction
      ].freeze

      COLONNES_DANS_ORDRE_EXPORT = %i[
        structure
        campagne
        debutee_le
        nom_beneficiaire
        par
        code_beneficiaire
        completude
        synthese_competences_de_base
        niveau_cefr
        niveau_cnef
        niveau_anlci_litteratie
        niveau_anlci_numeratie
        positionnement_niveau_litteratie
        positionnement_niveau_numeratie
        reponses_redaction
        taux_risque
        performance_collective
        agilite_organisationnelle
        securite_qualite
        mobilite_professionnelle
        score_cout
        bilan_situation
      ].freeze

      def colonnes_pour(compte:)
        return COLONNES_COMMUNES + COLONNES_EVA_PRO if utilisateur_entreprise?(compte)

        COLONNES_COMMUNES + COLONNES_HORS_EVA_PRO
      end

      def colonne_visible?(colonne, compte:)
        colonnes_pour(compte: compte).include?(colonne)
      end

      def masquer_colonnes_non_visibles(sheet:, compte:)
        colonnes_a_masquer(compte: compte).each do |index|
          sheet.column(index).hidden = true
        end
      end

      def appliquer_limite!(sheet:, collection:)
        limite = ImportExport::ExportXls::NOMBRE_MAX_LIGNES
        return collection unless collection.count > limite

        sheet << [ I18n.t("active_admin.export.limite_atteinte", limite: limite) ]
        collection.limit!(limite)
      end

      private

      def colonnes_a_masquer(compte:)
        colonnes_visibles = colonnes_pour(compte: compte)
        COLONNES_DANS_ORDRE_EXPORT
          .each_with_index
          .reject { |colonne, _| colonnes_visibles.include?(colonne) }
          .map { |_, index| index }
      end

      def utilisateur_entreprise?(compte)
        compte.utilisateur_entreprise?
      end
    end
  end
end
