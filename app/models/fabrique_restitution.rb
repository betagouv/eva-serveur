# frozen_string_literal: true

class FabriqueRestitution
  attr_reader :restitutions_selectionnees

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

    def restitutions(evaluation_id)
      Evenement.where(nom: 'demarrage', evaluation_id: evaluation_id)
    end

    def restitutions_selectionnees_ids(evaluation_id)
      restitutions_selectionnees ||= restitutions(evaluation_id).collect { |r| r.id.to_s }
      restitutions_selectionnees
    end

    def restitution_globale(evaluation_id, restitutions_selectionnees)
      @restitutions_selectionnees = restitutions_selectionnees
      return if restitutions_selectionnees_ids(evaluation_id).blank?

      evaluation = Evenement.find(restitutions_selectionnees_ids(evaluation_id).first).evaluation
      restitutions = restitutions_selectionnees_ids(evaluation_id).map do |id|
        depuis_evenement_id id
      end
      Restitution::Globale.new restitutions: restitutions, evaluation: evaluation
    end
  end
end
