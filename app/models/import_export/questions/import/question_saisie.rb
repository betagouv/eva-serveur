# frozen_string_literal: true

module ImportExport
  module Questions
    class Import
      class QuestionSaisie < ImportExport::Questions::Import::QuestionTest
        def initialize(headers_attendus)
          super('QuestionSaisie', headers_attendus)
        end

        private

        def cree_ou_actualise_question(cellules)
          question = super
          question.update!(suffix_reponse: cellules.suivant,
                           reponse_placeholder: cellules.suivant,
                           type_saisie: cellules.suivant,
                           texte_a_trous: cellules.suivant,
                           aide: cellules.suivant)
          cree_reponses('reponse', cellules) do |data|
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
