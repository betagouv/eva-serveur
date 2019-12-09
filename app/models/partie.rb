# frozen_string_literal: true

class Partie < ApplicationRecord
  belongs_to :evaluation
  belongs_to :situation
  has_many :evenements, -> { order(:date) }, foreign_key: :session_id, primary_key: :session_id

  validates :session_id, presence: true

  delegate :campagne, to: :evaluation

  def restitution
    FabriqueRestitution.instancie id
  end

  def persiste_restitution
    restitution.persiste
  end

  def moyenne_metrique(metrique)
    Partie
      .where(situation: situation)
      .where.not(metriques: {})
      .average("(metriques ->> '#{metrique}')::numeric")
      .to_f
      .round(2)
  end

  def moyenne_metriques
    Partie.where
          .not(metriques: {})
          .first
          &.metriques
          &.each_with_object({}) do |(metrique, valeur), memo|
      memo[metrique] = valeur.is_a?(Numeric) ? moyenne_metrique(metrique) : nil
    end
  end
end
