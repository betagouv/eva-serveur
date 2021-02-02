# frozen_string_literal: true

class SituationConfiguration < ApplicationRecord
  belongs_to :situation
  belongs_to :questionnaire, optional: true

  acts_as_list scope: :campagne_id

  validates :situation_id, uniqueness: { scope: :campagne_id }
end
