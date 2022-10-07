# frozen_string_literal: true

class DonneeSociodemographique < ApplicationRecord
  belongs_to :evaluation

  GENRES = ['Homme', 'Femme', 'Autre genre'].freeze
  enum :genre, GENRES.zip(GENRES).to_h
  NIVEAUX_ETUDES = ['Niveau Collège', 'Niveau CFG / DNB (BEPC)', 'Niveau CAP/ BEP', 'Niveau Bac',
                    'Niveau Bac +2', 'Supérieur Bac +2'].freeze
  enum :dernier_niveau_etude, NIVEAUX_ETUDES.zip(NIVEAUX_ETUDES).to_h
  SITUATIONS = ['Scolarisation', 'Formation professionnelle', 'Alternance', 'Emploi',
                'Sans emploi'].freeze
  enum :derniere_situation, SITUATIONS.zip(SITUATIONS).to_h

  validates :genre, inclusion: { in: GENRES, allow_blank: true }
  validates :dernier_niveau_etude, inclusion: { in: NIVEAUX_ETUDES, allow_blank: true }
  validates :derniere_situation, inclusion: { in: SITUATIONS, allow_blank: true }
end
