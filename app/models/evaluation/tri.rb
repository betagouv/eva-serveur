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
  end
end
