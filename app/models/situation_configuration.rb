# frozen_string_literal: true

class SituationConfiguration < ApplicationRecord
  belongs_to :campagne
  belongs_to :situation

  acts_as_list scope: :campagne
end
