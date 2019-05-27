# frozen_string_literal: true

class FabriqueEvaluation
  class << self
    def instancie(situation, evenements)
      classe_evaluation = {
        'inventaire' => Evaluation::Inventaire,
        'controle' => Evaluation::Controle,
        'tri' => Evaluation::Tri
      }

      classe_evaluation[situation].new(evenements)
    end

    def depuis_evenement_id(id)
      evenement = Evenement.find id
      evenements = Evenement.where(session_id: evenement.session_id).order(:date)
      instancie evenement.situation, evenements
    end
  end
end
