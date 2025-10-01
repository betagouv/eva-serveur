module ImportExport
  module Questions
    class Export
      class QuestionClicDansTexte < ImportExport::Questions::Export::QuestionTest
        private

        def remplis_champs(question)
          col = super
          @onglet.set_valeur(@ligne, col += 1, question.texte_sur_illustration)
          col
        end
      end
    end
  end
end
