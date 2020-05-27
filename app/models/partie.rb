# frozen_string_literal: true

class Partie < ApplicationRecord
  belongs_to :evaluation
  belongs_to :situation

  validates :session_id, presence: true

  delegate :campagne, to: :evaluation

  def display_name
    session_id
  end

  def moyenne_metrique(metrique)
    aggrege_metrique(:average, metrique)
  end

  def ecart_type_metrique(metrique)
    aggrege_metrique(:stddev_pop, metrique)
  end

  def moyenne_metriques
    @moyenne_metriques ||= collect_metriques_numeriques do |metrique|
      moyenne_metrique(metrique)
    end
  end

  def ecart_type_metriques
    @ecart_type_metriques ||= collect_metriques_numeriques do |metrique|
      ecart_type_metrique(metrique)
    end
  end

  def cote_z_metriques
    @cote_z_metriques ||= collect_metriques_numeriques do |metrique|
      if ecart_type_metriques[metrique].zero?
        0
      elsif metriques[metrique].present?
        cote_z_metrique(metrique)
      end
    end
  end

  private

  def cote_z_metrique(metrique)
    (
      (metriques[metrique] - moyenne_metriques[metrique]) / ecart_type_metriques[metrique]
    ).round(2)
  end

  def aggrege_metrique(fonction, metrique)
    Partie
      .where(situation: situation)
      .where.not(metriques: {})
      .calculate(fonction, "(metriques ->> '#{metrique}')::numeric")
      .to_f
      .round(2)
  end

  def collect_metriques_numeriques
    metriques.each_with_object({}) do |(metrique, valeur), memo|
      memo[metrique] = valeur.is_a?(Numeric) ? yield(metrique) : nil
    end
  end
end
