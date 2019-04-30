# frozen_string_literal: true

module Competence
  class ControleRapidite
    def initialize(evaluation_controle)
      @evaluation = evaluation_controle
    end

    def niveau
      nombre_erreur = @evaluation.nombre_ratees
      case nombre_erreur
      when 0 then Competence::NIVEAU_4
      when 1 then Competence::NIVEAU_3
      when 2 then Competence::NIVEAU_2
      else Competence::NIVEAU_1
      end
    end
  end
end
