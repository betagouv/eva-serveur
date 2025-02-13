# frozen_string_literal: true

module ImportExport
  module Questions
    class Export
      class QuestionClicDansTexte < ImportExport::Questions::Export
        private

        def remplis_champs_specifiques(col)
          @onglet.set_valeur(@ligne, col + 1, @question.texte_sur_illustration)
        end
      end
    end
  end
end
