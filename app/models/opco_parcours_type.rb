class OpcoParcoursType < ApplicationRecord
  belongs_to :opco
  belongs_to :parcours_type

  validates :parcours_type_id, uniqueness: { scope: :opco_id, message: :deja_associe_a_cet_opco }
end
