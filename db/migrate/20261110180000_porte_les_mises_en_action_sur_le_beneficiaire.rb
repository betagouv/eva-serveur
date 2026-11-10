class PorteLesMisesEnActionSurLeBeneficiaire < ActiveRecord::Migration[8.0]
  def change
    add_reference :mises_en_action, :beneficiaire, type: :uuid, index: true
    add_reference :mises_en_action, :structure, type: :uuid, index: true
    add_reference :mises_en_action, :repondue_par, type: :uuid, index: true
    add_column :mises_en_action, :remplacee_le, :datetime

    add_index :mises_en_action, %i[beneficiaire_id structure_id],
              unique: true,
              where: "deleted_at IS NULL AND remplacee_le IS NULL",
              name: "index_mises_en_action_en_cours_par_beneficiaire_et_structure"
  end
end
