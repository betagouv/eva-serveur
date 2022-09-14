# frozen_string_literal: true

class Partie < ApplicationRecord
  belongs_to :evaluation
  belongs_to :situation

  validates :session_id, presence: true, uniqueness: true

  delegate :campagne, to: :evaluation

  def display_name
    session_id
  end

  def metriques_numeriques
    metriques_numeriques = []
    metriques.each do |(metrique, valeur)|
      metriques_numeriques << metrique if valeur.is_a?(Numeric)
    end
    metriques_numeriques
  end

  def evenements
    Evenement.where(session_id: session_id)
  end
end
