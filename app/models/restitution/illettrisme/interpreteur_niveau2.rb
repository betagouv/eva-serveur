# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurNiveau2 < InterpreteurScores
      PALIERS = {
        score_ccf: %i[ccf_niveau1 ccf_niveau2 ccf_niveau3],
        score_syntaxe_orthographe: %i[syntaxe_orthographe_niveau1 syntaxe_orthographe_niveau2
                                      syntaxe_orthographe_niveau3],
        score_memorisation: %i[memorisation_niveau1 memorisation_niveau2 memorisation_niveau3],
        score_numeratie: %i[numeratie_niveau1 numeratie_niveau2 numeratie_niveau3]
      }.freeze
    end
  end
end
