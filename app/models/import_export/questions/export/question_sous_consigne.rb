# frozen_string_literal: true

module ImportExport
  module Questions
    class Export
      class QuestionSousConsigne < ImportExport::Questions::Export
        def initialize(questions, _headers_commun)
          headers = %i[libelle nom_technique illustration intitule_ecrit intitule_audio
                       consigne_ecrit consigne_audio description].freeze
          super(questions, headers)
        end

        private

        def remplis_champs_specifiques(col); end
      end
    end
  end
end
