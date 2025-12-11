class Partie < ApplicationRecord
  belongs_to :evaluation
  belongs_to :situation
  has_many :evenements, dependent: :destroy, foreign_key: :session_id, primary_key: :session_id

  validates :session_id, presence: true, uniqueness: true

  delegate :campagne, to: :evaluation

  acts_as_paranoid

  scope :situation_avec_nom_technique, ->(nom_technique) do
    situations = Situation.par_nom_technique(nom_technique).select(:id)
    where(situation_id: situations)
  end

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
