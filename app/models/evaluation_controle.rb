# frozen_string_literal: true

class EvaluationControle < EvaluationBase
  EVENEMENT = {
    PIECE_BIEN_PLACEE: 'pieceBienPlacee',
    PIECE_MAL_PLACEE: 'pieceMalPlacee',
    PIECE_RATEE: 'pieceRatee'
  }.freeze

  def nombre_bien_placees
    compte_nom_evenements EVENEMENT[:PIECE_BIEN_PLACEE]
  end

  def nombre_mal_placees
    compte_nom_evenements EVENEMENT[:PIECE_MAL_PLACEE]
  end

  def nombre_ratees
    compte_nom_evenements EVENEMENT[:PIECE_RATEE]
  end

  def evenements_pieces
    noms_evenements_pieces =
      EVENEMENT.slice(:PIECE_BIEN_PLACEE, :PIECE_MAL_PLACEE, :PIECE_RATEE).values
    @evenements.find_all { |e| noms_evenements_pieces.include?(e.nom) }
  end
end
