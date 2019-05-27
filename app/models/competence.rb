# frozen_string_literal: true

module Competence
  NIVEAU_4 = 4
  NIVEAU_3 = 3
  NIVEAU_2 = 2
  NIVEAU_1 = 1
  NIVEAU_INDETERMINE = :indetermine

  NIVEAUX = [NIVEAU_INDETERMINE, NIVEAU_1, NIVEAU_2, NIVEAU_3, NIVEAU_4].freeze

  PERSEVERANCE = :perseverance
  COMPREHENSION_CONSIGNE = :comprehension_consigne
  RAPIDITE = :rapidite
  COMPARAISON_TRI = :comparaison_tri
  ATTENTION_CONCENTRATION = :attention_concentration
  ORGANISATION_METHODE = :organisation_methode
  VIGILANCE_CONTROLE = :vigilance_controle
end
