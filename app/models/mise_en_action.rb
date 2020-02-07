# frozen_string_literal: true

class MiseEnAction < ApplicationRecord
  validates :elements_decouverts, :recommandations_candidat, inclusion: { in: [true, false] }
  validates :type_recommandation, presence: true, if: :recommandations_candidat?
  enum type_recommandation: %i[ateliers formation metier]
end
