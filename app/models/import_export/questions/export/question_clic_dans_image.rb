# frozen_string_literal: true

module ImportExport
  module Questions
    class Export
      class QuestionClicDansImage < ImportExport::Questions::Export
        def initialize(questions, headers_commun)
          headers = headers_commun + %i[zone_cliquable image_au_clic].freeze
          super(questions, headers)
        end

        def remplis_champs_specifiques(col)
          @onglet.set_valeur(@ligne, col += 1, @question.zone_cliquable_url)
          @onglet.set_valeur(@ligne, col += 1, @question.image_au_clic_url) # rubocop:disable Lint/UselessAssignment
        end
      end
    end
  end
end
