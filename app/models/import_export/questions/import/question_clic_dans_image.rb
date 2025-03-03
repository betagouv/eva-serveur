# frozen_string_literal: true

module ImportExport
  module Questions
    class Import
      class QuestionClicDansImage < ImportExport::Questions::Import::QuestionTest
        def initialize(headers_attendus)
          super('QuestionClicDansImage', headers_attendus)
        end

        private

        def cree_ou_actualise_question(cellules)
          question = super
          attache_fichier(question.zone_cliquable, cellules.suivant,
                          "#{cellules.cell(1)}_zone_cliquable")
          attache_fichier(question.image_au_clic, cellules.suivant,
                          "#{cellules.cell(1)}_image_au_clic")
        end
      end
    end
  end
end
