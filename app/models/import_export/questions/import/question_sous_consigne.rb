# frozen_string_literal: true

module ImportExport
  module Questions
    class Import
      class QuestionSousConsigne < ImportExport::Questions::Import
        def initialize(headers_attendus)
          super('QuestionSousConsigne', headers_attendus)
        end

        private

        def update_champs_specifiques; end
      end
    end
  end
end
