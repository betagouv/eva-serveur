# frozen_string_literal: true

module ImportExport
  module Questions
    class Import
      class QuestionSaisie < ImportExport::Questions::Import
        def initialize(headers_attendus)
          super('QuestionSaisie', headers_attendus)
        end

        private

        def update_champs_specifiques
          @question.update!(suffix_reponse: @row[8], reponse_placeholder: @row[9],
                            type_saisie: @row[10], texte_a_trous: @row[11])
          cree_reponses('reponse') do |data|
            cree_reponse_saisie(data)
          end
        end

        def cree_reponse_saisie(data)
          cree_reponse_generique(
            intitule: data['intitule'],
            nom_technique: data['nom_technique'],
            type_choix: data['type_choix']
          )
        end
      end
    end
  end
end
