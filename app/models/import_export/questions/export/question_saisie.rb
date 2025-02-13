# frozen_string_literal: true

module ImportExport
  module Questions
    class Export
      class QuestionSaisie < ImportExport::Questions::Export
        private

        def remplis_champs_specifiques(col)
          @onglet.set_valeur(@ligne, col += 1, @question.suffix_reponse)
          @onglet.set_valeur(@ligne, col += 1, @question.reponse_placeholder)
          @onglet.set_valeur(@ligne, col += 1, @question.type_saisie)
          @onglet.set_valeur(@ligne, col += 1, @question.texte_a_trous)
          @question.reponses.each_with_index do |reponse, index|
            ajoute_saisies(reponse, index, col + 1)
          end
        end

        def ajoute_saisies(reponse, index, col_debut)
          columns = %w[intitule nom_technique type_choix]
          columns.each_with_index do |col, i|
            colonne = col_debut + (index * columns.size) + i
            @onglet.set_valeur(0, colonne, "reponse_#{index + 1}_#{col}")
            @onglet.set_valeur(@ligne, colonne, reponse.send(col))
          end
        end
      end
    end
  end
end
