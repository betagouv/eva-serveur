# frozen_string_literal: true

module ImportExport
  module Questions
    class Import
      class QuestionQcm < ImportExport::Questions::Import
        def initialize(headers_attendus)
          super('QuestionQcm', headers_attendus)
        end

        private

        def update_champs_specifiques(question, col)
          col = initialise_modalite_reponse(question, col)
          question.update!(type_qcm: @row[col + 1])
          cree_reponses('choix') do |data|
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
