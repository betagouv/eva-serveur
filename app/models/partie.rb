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
           :cote_z_metriques,
           to: :aggregateur_metrique

  def display_name
    session_id
  end

  def aggregateur_metrique
    @aggregateur_metrique ||= Restitution::AggregateurMetrique
                              .new(metriques, proc { Partie.where(situation: situation) })
  end
end
