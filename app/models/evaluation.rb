# frozen_string_literal: true

class Evaluation < ApplicationRecord
  validates :nom, presence: true
  belongs_to :campagne
end
