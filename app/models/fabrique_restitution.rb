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

    def depuis_session_id(session_id)
      evenements = Evenement.where(session_id: session_id).order(:date)
      campagne = evenements.first.evaluation.campagne
      situation = evenements.first.situation
      instancie situation, campagne, evenements
    end

    def initialise_selection(evaluation, parties_selectionnees_ids)
      parties_selectionnees_ids || evaluation.parties.map(&:session_id)
    end

    def restitution_globale(evaluation, parties_selectionnees_ids = nil)
      parties_selectionnees_ids =
        initialise_selection(evaluation, parties_selectionnees_ids)
      parties_retenues = parties_selectionnees_ids.map do |id|
        depuis_session_id id
      end
      Restitution::Globale.new restitutions: parties_retenues, evaluation: evaluation
    end
  end
end
