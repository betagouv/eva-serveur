# frozen_string_literal: true

module ImportExport
  module Questions
    class Export
      class QuestionQcm < ImportExport::Questions::Export
        def initialize(questions, headers_commun)
          headers = headers_commun + %i[type_qcm].freeze
          super(questions, headers)
        end

        private

        def remplis_champs_specifiques(col)
          @onglet.set_valeur(@ligne, col += 1, @question.type_qcm)
          @question.choix.each_with_index do |choix, index|
            ajoute_choix(choix, index, col + 1)
          end
        end

        def ajoute_choix(choix, index, col_debut)
          columns = %w[intitule nom_technique type_choix audio_url]
          columns.each_with_index do |col, i|
            colonne = col_debut + (index * columns.size) + i
            @onglet.set_valeur(0, colonne, "choix_#{index + 1}_#{col}")
            @onglet.set_valeur(@ligne, colonne, choix.send(col))
          end
        end
      end
    end
  end
end
