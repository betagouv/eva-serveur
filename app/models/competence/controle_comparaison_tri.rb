# frozen_string_literal: true

module Competence
  class ControleComparaisonTri
    def initialize(evaluation_controle)
      @evaluation = evaluation_controle
      @evaluation_hors_4_premiers = evaluation_controle.shift(4)
    end

    def niveau
      return Competence::NIVEAU_INDETERMINE if @evaluation.evenements.count < 4

      nombre_erreur = @evaluation_hors_4_premiers.nombre_mal_placees
      case nombre_erreur
      when 0 then Competence::NIVEAU_4
      when 1 then Competence::NIVEAU_3
      when 2 then Competence::NIVEAU_2
      else Competence::NIVEAU_1
      end
    end
  end
end
