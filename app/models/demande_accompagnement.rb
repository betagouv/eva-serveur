# frozen_string_literal: true

class DemandeAccompagnement < ApplicationRecord
  belongs_to :compte
  belongs_to :evaluation

  validates :conseiller_nom, :conseiller_prenom, :conseiller_email,
            :conseiller_telephone, :probleme_rencontre, presence: true

  PROBLEMES_RENCONTRE_COURANTS = [
    'Je ne sais pas où trouver une formation dans la zone géographique',
    "Il n'y a pas de place dans les organismes de formation avec lesquels je travaille",
    'Je ne sais pas comment faire financer une formation',
    "Je cherche à lever les freins périphériques au préalable d'une entrée en formation"
  ].freeze

  attr_accessor :probleme_rencontre_custom
end
