module ImportExport
  module Questions
    class Export
      class QuestionClicDansImage < ImportExport::Questions::Export::QuestionTest
        private

        def remplis_champs(question)
          col = super
          @onglet.set_valeur(@ligne, col += 1, question.zone_cliquable_url)
          @onglet.set_valeur(@ligne, col += 1, question.image_au_clic_url)
          col
        end
      end
    end
  end
end
