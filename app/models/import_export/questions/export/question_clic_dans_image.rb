# frozen_string_literal: true

module ImportExport
  module Questions
    class Export
      class QuestionClicDansImage < ImportExport::Questions::Export
        private

        def remplis_champs_specifiques(col)
          @onglet.set_valeur(@ligne, col += 1, @question.zone_cliquable_url)
          @onglet.set_valeur(@ligne, col + 1, @question.image_au_clic_url)
        end
      end
    end
  end
end
