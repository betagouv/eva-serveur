class StructureOpco < ApplicationRecord
  belongs_to :structure
  belongs_to :opco

  validates :structure_id, uniqueness: { scope: :opco_id }
end
