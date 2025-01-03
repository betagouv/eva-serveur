# frozen_string_literal: true

class FabriqueRestitution
  class << self
    def instancie(partie)
      evenements = Evenement.where(partie: partie.session_id).order(:position).order(:date)
      classe_restitution = "Restitution::#{partie.situation.nom_technique.camelize}".constantize
      classe_restitution.new(partie.campagne, evenements)
    end

    def initialise_selection(evaluation, parties_selectionnees_ids)
      parties_selectionnees_ids || Partie.where(evaluation_id: evaluation).pluck(:id)
    end

    def restitution_globale(evaluation, parties_selectionnees_ids = nil)
      restitutions_retenues = instancie_restitutions(evaluation, parties_selectionnees_ids)
      Restitution::Globale.new evaluation: evaluation, restitutions: restitutions_retenues
    end

    def instancie_restitutions(evaluation, parties_selectionnees_ids = nil)
      parties_selectionnees_ids =
        initialise_selection(evaluation, parties_selectionnees_ids)
      situation_valides_ids = evaluation.campagne.situations_configurations.select(:situation_id)
      parties = Partie.where(id: parties_selectionnees_ids,
                             situation_id: situation_valides_ids)
                      .includes(:situation).includes(evaluation: :campagne)
                      .order(:created_at)
      restitutions = parties.map { |partie| instancie partie }
      selectionne_restitutions(restitutions)
    end

    def selectionne_restitutions(restitutions)
      restitutions = restitutions.reject { |restitution| restitution.evenements.empty? }
      restitutions_par_situation = restitutions.group_by(&:situation)
      restitutions_par_situation.values.map do |restitutions_selectionnees|
        restitution_selectionne = restitutions_selectionnees.find(&:termine?)
        restitution_selectionne ||= restitutions_selectionnees.first
        restitution_selectionne
      end
    end
  end
end
