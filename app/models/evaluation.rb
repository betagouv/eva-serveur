# frozen_string_literal: true

class Evaluation < ApplicationRecord
  validates :nom, presence: true
  belongs_to :campagne, counter_cache: :nombre_evaluations

  def display_name
    nom
  end

  def parties
    Evenement.where(evaluation: self).select(:session_id).distinct.map do |evenement|
      Partie.new(evenement.session_id)
    end
  end
end
