# frozen_string_literal: true

class DonneeSociodemographique < ApplicationRecord
  belongs_to :evaluation

  GENRES = %w[homme femme autre].freeze
  enum :genre, GENRES.zip(GENRES).to_h
  NIVEAUX_ETUDES = %w[college cfg_dnb_bepc cap_bep bac
                      bac_plus2 superieur_bac_plus2].freeze
  enum :dernier_niveau_etude, NIVEAUX_ETUDES.zip(NIVEAUX_ETUDES).to_h
  SITUATIONS = %w[scolarisation formation_professionnelle alternance emploi
                  sans_emploi].freeze
  enum :derniere_situation, SITUATIONS.zip(SITUATIONS).to_h

  acts_as_paranoid

  def to_s
    [
      age,
      genre,
      dernier_niveau_etude,
      derniere_situation
    ].compact.join(' | ')
  end
end
