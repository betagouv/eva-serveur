module Restitution
  class Tri < Base
    PIECES_TOTAL = 48

    EVENEMENT = {
      PIECE_BIEN_PLACEE: "pieceBienPlacee",
      PIECE_MAL_PLACEE: "pieceMalPlacee"
    }.freeze

    def termine?
      super || nombre_bien_placees == PIECES_TOTAL
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
      calcule_competences(
        ::Competence::PERSEVERANCE => Restitution::Tri::Perseverance,
        ::Competence::COMPREHENSION_CONSIGNE => Restitution::Tri::ComprehensionConsigne,
        ::Competence::RAPIDITE => Restitution::Tri::Rapidite,
        ::Competence::COMPARAISON_TRI => Restitution::Tri::ComparaisonTri
      )
    end
  end
end
