# frozen_string_literal: true

module ImportExport
  module Questions
    class Import
      class QuestionClicDansTexte < ImportExport::Questions::Import
        def initialize(headers_attendus)
          super('QuestionClicDansTexte', headers_attendus)
        end

        private

        def update_champs_specifiques(question, col)
          col = initialise_modalite_reponse(question, col)
          question.update!(texte_sur_illustration: @row[col + 1])
        end
      end
    end
  end
end
