# frozen_string_literal: true

class Partie < ApplicationRecord
  belongs_to :evaluation
  belongs_to :situation

  has_many :evenements, foreign_key: :session_id, primary_key: :session_id, dependent: :destroy

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
end
