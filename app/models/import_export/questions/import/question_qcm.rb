# frozen_string_literal: true

module ImportExport
  module Questions
    class Import
      class QuestionQcm < ImportExport::Questions::Import::QuestionAvecModaliteReponse
        def initialize(headers_attendus)
          super('QuestionQcm', headers_attendus)
        end

        private

        def cree_ou_actualise_question(cellules)
          question = super
          question.update!(type_qcm: cellules.suivant)
          cree_reponses('choix', cellules) do |data|
            cree_choix(question, data)
          end
        end

        def cree_choix(question, data)
          choix = cree_reponse_generique(
            question_id: question.id,
            intitule: data['intitule'],
            nom_technique: data['nom_technique'],
            type_choix: data['type_choix']
          )
          attache_fichier(choix.audio, data['audio_url'], data['nom_technique'])
          attache_fichier(choix.illustration, data['illustration_url'], data['nom_technique'])
        end
      end
    end
  end
end
