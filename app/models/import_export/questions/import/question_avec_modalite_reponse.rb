# frozen_string_literal: true

module ImportExport
  module Questions
    class Import
      class QuestionAvecModaliteReponse < ImportExport::Questions::Import
        def cree_ou_actualise_question(cellules)
          question = super
          cree_transcription(question.id, :modalite_reponse, cellules.suivant, cellules.suivant,
                             "#{cellules.cell(1)}_modalite_reponse")
          question.update!(description: cellules.suivant,
                           demarrage_audio_modalite_reponse: cellules.suivant)
          question
        end
      end
    end
  end
end
