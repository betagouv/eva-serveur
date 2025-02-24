# frozen_string_literal: true

module ImportExport
  module Questions
    class Import
      class QuestionClicDansImage < ImportExport::Questions::Import
        def initialize(headers_attendus)
          super('QuestionClicDansImage', headers_attendus)
        end

        private

        def update_champs_specifiques(question, col)
          col = initialise_modalite_reponse(question, col)
          attache_fichier(question.zone_cliquable, @row[col += 1],
                          "#{@row[1]}_zone_cliquable")
          attache_fichier(question.image_au_clic, @row[col + 1], "#{@row[1]}_image_au_clic")
        end
      end
    end
  end
end
