# frozen_string_literal: true

class Evaluation < ApplicationRecord
  validates :nom, :campagne, presence: true
  belongs_to :campagne, counter_cache: :nombre_evaluations

  def display_name
    nom
  end
end
