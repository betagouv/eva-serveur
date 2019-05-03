# frozen_string_literal: true

class EvaluationControle < EvaluationBase
  PIECES_TOTAL = 60

  EVENEMENT = {
    PIECE_BIEN_PLACEE: 'pieceBienPlacee',
    PIECE_MAL_PLACEE: 'pieceMalPlacee',
    PIECE_RATEE: 'pieceRatee'
  }.freeze

  def termine?
    evenements_pieces.count == PIECES_TOTAL
  end

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

  def shift(nombre)
    self.class.new(evenements_pieces[nombre..-1])
  end

  def competences
    {
      Competence::RAPIDITE => Competence::ControleRapidite,
      Competence::COMPARAISON_TRI => Competence::ControleComparaisonTri,
      Competence::ATTENTION_CONCENTRATION => Competence::ControleAttentionConcentration
    }.each_with_object({}) do |(competence, classe), resultat|
      resultat[competence] = classe.new(self).niveau
    end
  end
end
