# frozen_string_literal: true

module ImportExport
  module Questions
    class Import
      class QuestionGlisserDeposer < ImportExport::Questions::Import
        def initialize(headers_attendus)
          super('QuestionGlisserDeposer', headers_attendus)
        end

        private

        def update_champs_specifiques(question, col)
          col = initialise_modalite_reponse(question, col)
          attache_fichier(question.zone_depot, @row[col += 1], "#{@row[1]}_zone_depot")
          question.update!(orientation: @row[col + 1])
          cree_reponses('reponse') do |data|
            cree_reponse(question.id, data)
          end
        end

        def cree_reponse(question_id, data)
          reponse = cree_reponse_generique(
            question_id: question_id,
            intitule: nil,
            nom_technique: data['nom_technique'],
            type_choix: data['type_choix'],
            position_client: data['position_client']
          )
          attache_fichier(reponse.illustration, data['illustration_url'], data['nom_technique'])
        end
      end
    end
  end
end
