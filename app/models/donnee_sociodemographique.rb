# frozen_string_literal: true

class DonneeSociodemographique < ApplicationRecord
  belongs_to :evaluation

  validates :evaluation_id, uniqueness: true

  GENRES = %w[homme femme autre].freeze
  enum :genre, GENRES.zip(GENRES).to_h
  NIVEAUX_ETUDES = %w[pas_etudie college cfg_dnb cap_bep bac
                      bac_plus2 superieur_bac_plus2].freeze
  enum :dernier_niveau_etude, NIVEAUX_ETUDES.zip(NIVEAUX_ETUDES).to_h
  SITUATIONS = %w[scolarisation formation_professionnelle alternance en_emploi
                  sans_emploi].freeze
  enum :derniere_situation, SITUATIONS.zip(SITUATIONS).to_h

  acts_as_paranoid

  def to_s
    [
      age,
      genre,
      langue_maternelle,
      lieu_scolarite,
      dernier_niveau_etude,
      derniere_situation
    ].compact.join(" | ")
  end
end
