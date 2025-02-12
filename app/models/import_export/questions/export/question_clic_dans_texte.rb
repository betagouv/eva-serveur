# frozen_string_literal: true

module ImportExport
  module Questions
    class Export
      class QuestionClicDansTexte < ImportExport::Questions::Export
        def initialize(questions, headers_commun)
          headers = headers_commun + %i[texte_sur_illustration].freeze
          super(questions, headers)
        end

        private

        def remplis_champs_specifiques(col)
          @onglet.set_valeur(@ligne, col += 1, @question.texte_sur_illustration) # rubocop:disable Lint/UselessAssignment
        end
      end
    end
  end
end
