# frozen_string_literal: true

module ImportExport
  module Questions
    class Import
      class QuestionSaisie < ImportExport::Questions::Import
        def initialize(headers_attendus)
          super('QuestionSaisie', headers_attendus)
        end

        private

        def update_champs_specifiques(col_debut)
          @question.update!(suffix_reponse: @row[col_debut += 1],
                            reponse_placeholder: @row[col_debut += 1],
                            type_saisie: @row[col_debut += 1],
                            texte_a_trous: @row[col_debut + 1])
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
