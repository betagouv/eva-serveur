class MigreMisesEnActionDejaNonEffectuees < ActiveRecord::Migration[7.0]
  class MiseEnAction < ApplicationRecord
    REMEDIATIONS = %w[formation_competences_de_base formation_metier
                      dispositif_remobilisation levee_freins_peripheriques
                      indetermine].freeze
    DIFFICULTES = %w[aucune_offre_formation offre_formation_inaccessible
                     freins_peripheriques accompagnement_necessaire
                     indetermine].freeze
    attribute :remediation, :string
    attribute :difficulte, :string
    enum :remediation, REMEDIATIONS.zip(REMEDIATIONS).to_h, suffix: true
    enum :difficulte, DIFFICULTES.zip(DIFFICULTES).to_h, suffix: true
  end
  def change
    MiseEnAction.where(effectuee: false).where(difficulte: nil).update_all(difficulte: 'indetermine')
  end
end
