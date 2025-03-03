# frozen_string_literal: true

module ImportExport
  module Questions
    class Import
      class QuestionClicDansTexte < ImportExport::Questions::Import::QuestionTest
        def initialize(headers_attendus)
          super('QuestionClicDansTexte', headers_attendus)
        end

        private

        def cree_ou_actualise_question(cellules)
          question = super
          question.update!(texte_sur_illustration: cellules.suivant)
        end
      end
    end
  end
end
