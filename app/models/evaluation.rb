# frozen_string_literal: true

class Evaluation < ApplicationRecord
  validates :nom, presence: true
end
