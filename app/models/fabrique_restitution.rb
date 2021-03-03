# frozen_string_literal: true

class FabriqueRestitution
  class << self
    def instancie(partie)
      evenements = Evenement.where(partie: partie.session_id).order(:date)
      classe_restitution = "Restitution::#{partie.situation.nom_technique.camelize}".constantize
      classe_restitution.new(partie.campagne, evenements)
    end

    def initialise_selection(evaluation, parties_selectionnees_ids)
      parties_selectionnees_ids || Partie.where(evaluation_id: evaluation).pluck(:id)
    end

    def restitution_globale(evaluation, parties_selectionnees_ids = nil)
      parties_selectionnees_ids =
        initialise_selection(evaluation, parties_selectionnees_ids)
      parties = Partie.where(id: parties_selectionnees_ids)
                      .includes(:situation).includes(evaluation: :campagne)
      restitutions_retenues = parties.map do |partie|
        instancie partie
      end
      Restitution::Globale.new restitutions: restitutions_retenues, evaluation: evaluation
    end
  end
end
