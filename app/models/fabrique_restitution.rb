# frozen_string_literal: true

class FabriqueRestitution
  class << self
    def instancie(situation, campagne, evenements)
      classe_restitution = {
        'inventaire' => Restitution::Inventaire,
        'controle' => Restitution::Controle,
        'tri' => Restitution::Tri,
        'questions' => Restitution::Questions,
        'securite' => Restitution::Securite
      }

      classe_restitution[situation.nom_technique].new(campagne, evenements)
    end

    def depuis_evenement_id(id)
      evenement = Evenement.find id
      campagne = evenement.evaluation.campagne
      evenements = Evenement.where(session_id: evenement.session_id).order(:date)
      instancie evenement.situation, campagne, evenements
    end

    def restitutions(evaluation)
      Evenement.where(nom: 'demarrage', evaluation_id: evaluation)
    end

    def restitution_globale(evaluation, restitutions_selectionnees_ids = nil)
      restitutions_selectionnees_ids ||= restitutions(evaluation).pluck(:id)
      restitutions_situation_retenues = restitutions_selectionnees_ids.map do |id|
        depuis_evenement_id id
      end
      Restitution::Globale.new restitutions: restitutions_situation_retenues, evaluation: evaluation
    end
  end
end
