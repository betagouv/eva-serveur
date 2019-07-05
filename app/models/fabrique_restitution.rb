# frozen_string_literal: true

class FabriqueRestitution
  class << self
    def instancie(situation, evenements)
      classe_restitution = {
        'inventaire' => Restitution::Inventaire,
        'controle' => Restitution::Controle,
        'tri' => Restitution::Tri
      }

      classe_restitution[situation.nom_technique].new(evenements)
    end

    def depuis_evenement_id(id)
      evenement = Evenement.find id
      evenements = Evenement.where(session_id: evenement.session_id).order(:date)
      instancie evenement.situation, evenements
    end
  end
end
