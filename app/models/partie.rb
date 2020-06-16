# frozen_string_literal: true

class Partie < ApplicationRecord
  belongs_to :evaluation
  belongs_to :situation

  validates :session_id, presence: true

  delegate :campagne, to: :evaluation
  delegate :moyenne_metrique,
           :ecart_type_metrique,
           :moyenne_metriques,
           :ecart_type_metriques,
           to: :standardisateur

  def display_name
    session_id
  end

  def cote_z_metriques
    @cote_z_metriques ||= metriques.each_with_object({}) do |(metrique, valeur), memo|
      memo[metrique] = standardisateur.standardise(metrique, valeur)
    end
  end

  private

  def standardisateur
    @standardisateur ||= Restitution::Standardisateur.new(
      metriques_numeriques,
      proc { Partie.where(situation: situation) }
    )
  end

  def metriques_numeriques
    metriques_numeriques = []
    metriques.each do |(metrique, valeur)|
      metriques_numeriques << metrique if valeur.is_a?(Numeric)
    end
    metriques_numeriques
  end
end
