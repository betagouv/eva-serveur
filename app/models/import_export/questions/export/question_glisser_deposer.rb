# frozen_string_literal: true

module ImportExport
  module Questions
    class Export
      class QuestionGlisserDeposer < ImportExport::Questions::Export::QuestionTest
        private

        def remplis_champs
          col = super
          @onglet.set_valeur(@ligne, col += 1, @question.zone_depot_url)
          @onglet.set_valeur(@ligne, col += 1, @question.orientation)
          @question.reponses.each_with_index do |choix, index|
            ajoute_reponses(choix, index, col + 1)
          end
        end

        def ajoute_reponses(choix, index, col_debut)
          columns = %w[nom_technique position_client type_choix illustration_url]
          columns.each_with_index do |col, i|
            colonne = col_debut + (index * columns.size) + i
            @onglet.set_valeur(0, colonne, "reponse_#{index + 1}_#{col}")
            @onglet.set_valeur(@ligne, colonne, choix.send(col).to_s)
          end
        end
      end
    end
  end
end
