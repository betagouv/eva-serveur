class RecalculeEvaluationsEvaPro < ActiveRecord::Migration[7.2]
  def up
    recalcule_evaluations_evapro
  end

  def down; end

  private

  def recalcule_evaluations_evapro
    evaluations_evapro = Evaluation.includes(:parties).joins(campagne: :parcours_type).where(campagnes: { parcours_type: { type_de_programme: :diagnostic_entreprise } } )

    evaluations_evapro.find_each do |evaluation|
      parties_ids = evaluation.parties.map(&:id)

      restitution_globale = FabriqueRestitution.restitution_globale(evaluation, parties_ids)
      restitution_globale.persiste
    end
  end
end
