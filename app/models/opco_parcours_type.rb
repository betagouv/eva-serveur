class OpcoParcoursType < ApplicationRecord
  belongs_to :opco
  belongs_to :parcours_type

  validates :opco_id, uniqueness: { scope: :parcours_type_id }
end
