module Restitution
  class Controle < Base
    PIECES_TOTAL = 60

    EVENEMENT = {
      PIECE_BIEN_PLACEE: "pieceBienPlacee",
      PIECE_MAL_PLACEE: "pieceMalPlacee",
      PIECE_NON_TRIEE: "pieceRatee"
    }.freeze

    def termine?
      super || evenements_pieces.count == PIECES_TOTAL
    end

    def nombre_bien_placees
      compte_nom_evenements EVENEMENT[:PIECE_BIEN_PLACEE]
    end

    def nombre_mal_placees
      compte_nom_evenements EVENEMENT[:PIECE_MAL_PLACEE]
    end

    def nombre_non_triees
      compte_nom_evenements EVENEMENT[:PIECE_NON_TRIEE]
    end

    def nombre_pieces
      evenements_pieces.size
    end

    def nombre_loupees
      nombre_mal_placees + nombre_non_triees
    end

    def noms_evenements_pieces
      EVENEMENT.slice(:PIECE_BIEN_PLACEE, :PIECE_MAL_PLACEE, :PIECE_NON_TRIEE).values
    end

    def evenements_pieces
      evenements.find_all { |e| noms_evenements_pieces.include?(e.nom) }
    end

    def enleve_premiers_evenements_pieces(nombre)
      compteur = 0
      nouveaux_evenements = evenements.reject do |evenement|
        noms_evenements_pieces.include?(evenement.nom) && (compteur += 1) <= nombre
      end
      self.class.new(campagne, nouveaux_evenements)
    end

    def competences
      calcule_competences(
        ::Competence::PERSEVERANCE => Controle::Perseverance,
        ::Competence::COMPREHENSION_CONSIGNE => Controle::ComprehensionConsigne,
        ::Competence::RAPIDITE => Controle::Rapidite,
        ::Competence::COMPARAISON_TRI => Controle::ComparaisonTri,
        ::Competence::ATTENTION_CONCENTRATION => Controle::AttentionConcentration
      )
    end
  end
end
