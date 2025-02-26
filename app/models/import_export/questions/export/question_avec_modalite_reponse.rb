# frozen_string_literal: true

module ImportExport
  module Questions
    class Export
      class QuestionAvecModaliteReponse < ImportExport::Questions::Export
        private

        def remplis_champs
          col = super
          @onglet.set_valeur(@ligne, col += 1, @question.transcription_modalite_reponse&.ecrit)
          @onglet.set_valeur(@ligne, col += 1, @question.transcription_modalite_reponse&.audio_url)
          @onglet.set_valeur(@ligne, col += 1, @question.description)
          @onglet.set_valeur(@ligne, col += 1, @question.demarrage_audio_modalite_reponse)
          col
        end
      end
    end
  end
end
