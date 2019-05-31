# frozen_string_literal: true

module Evaluation
  class Tri < Base
    PIECES_TOTAL = 48

    EVENEMENT = {
      PIECE_BIEN_PLACEE: 'pieceBienPlacee',
      PIECE_MAL_PLACEE: 'pieceMalPlacee'
    }.freeze

    def termine?
      nombre_bien_placees == PIECES_TOTAL
    end

    def nombre_bien_placees
      compte_nom_evenements EVENEMENT[:PIECE_BIEN_PLACEE]
    end

    def nombre_mal_placees
      compte_nom_evenements EVENEMENT[:PIECE_MAL_PLACEE]
    end

    def nombre_non_triees
      PIECES_TOTAL - nombre_bien_placees
    end

    def competences
      {
        ::Competence::COMPARAISON_TRI => Tri::ComparaisonTri,
        ::Competence::RAPIDITE => Tri::Rapidite,
        ::Competence::PERSEVERANCE => Tri::Perseverance
      }.each_with_object({}) do |(competence, classe), resultat|
        resultat[competence] = classe.new(self).niveau
      end
    end
  end
end
