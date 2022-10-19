# frozen_string_literal: true

class ConditionsPassation < ApplicationRecord
  belongs_to :evaluation

  acts_as_paranoid
end
