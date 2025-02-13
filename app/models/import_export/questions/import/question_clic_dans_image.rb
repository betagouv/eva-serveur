# frozen_string_literal: true

module ImportExport
  module Questions
    class Import
      class QuestionClicDansImage < ImportExport::Questions::Import
        def initialize(headers_attendus)
          super('QuestionClicDansImage', headers_attendus)
        end

        private

        def update_champs_specifiques
          attache_fichier(@question.image_au_clic, @row[9])
          attache_fichier(@question.zone_cliquable, @row[8])
        end
      end
    end
  end
end
