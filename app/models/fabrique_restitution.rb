# frozen_string_literal: true

class FabriqueRestitution
  class << self
    def instancie(situation, campagne, evenements)
      classe_restitution = {
        'inventaire' => Restitution::Inventaire,
        'controle' => Restitution::Controle,
        'tri' => Restitution::Tri,
        'questions' => Restitution::Questions
      }

      classe_restitution[situation.nom_technique].new(campagne, evenements)
    end

    def depuis_evenement_id(id)
      evenement = Evenement.find id
      campagne = evenement.evaluation.campagne
      evenements = Evenement.where(session_id: evenement.session_id).order(:date)
      instancie evenement.situation, campagne, evenements
    end
  end
end
