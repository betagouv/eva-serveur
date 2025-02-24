# frozen_string_literal: true

module ImportExport
  module Questions
    class Import
      class QuestionSaisie < ImportExport::Questions::Import
        def initialize(headers_attendus)
          super('QuestionSaisie', headers_attendus)
        end

        private

        def update_champs_specifiques(question, col)
          col = initialise_modalite_reponse(question, col)
          question.update!(suffix_reponse: @row[col += 1],
                           reponse_placeholder: @row[col += 1],
                           type_saisie: @row[col += 1],
                           texte_a_trous: @row[col + 1])
          cree_reponses('reponse') do |data|
            cree_reponse_saisie(question.id, data)
          end
        end

        def cree_reponse_saisie(question_id, data)
          cree_reponse_generique(
            question_id: question_id,
            intitule: data['intitule'],
            nom_technique: data['nom_technique'],
            type_choix: data['type_choix']
          )
        end
      end
    end
  end
end
