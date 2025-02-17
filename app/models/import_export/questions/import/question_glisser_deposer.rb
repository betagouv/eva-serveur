# frozen_string_literal: true

module ImportExport
  module Questions
    class Import
      class QuestionGlisserDeposer < ImportExport::Questions::Import
        def initialize(headers_attendus)
          super('QuestionGlisserDeposer', headers_attendus)
        end

        private

        def update_champs_specifiques
          attache_fichier(@question.zone_depot, @row[8])
          cree_reponses('reponse') do |data|
            cree_reponse(data)
          end
        end

        def cree_reponse(data)
          reponse = cree_reponse_generique(
            intitule: nil,
            nom_technique: data['nom_technique'],
            type_choix: data['type_choix'],
            position_client: data['position_client']
          )
          attache_fichier(reponse.illustration, data['illustration_url'])
        end
      end
    end
  end
end
