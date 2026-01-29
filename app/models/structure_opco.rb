class StructureOpco < ApplicationRecord
  belongs_to :structure
  belongs_to :opco

  validates :structure_id, uniqueness: { scope: :opco_id }

  def self.opco_financeur_pour_structure_id(structure_id)
    ids = where(structure_id: structure_id).select(:opco_id)
    Opco.financeurs.where(id: ids).first
  end
end
