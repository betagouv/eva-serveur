# frozen_string_literal: true

class SituationConfiguration < ApplicationRecord
  belongs_to :campagne
  belongs_to :situation
end
