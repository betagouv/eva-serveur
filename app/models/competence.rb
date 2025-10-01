module Competence
  NIVEAU_4 = 4
  NIVEAU_3 = 3
  NIVEAU_2 = 2
  NIVEAU_1 = 1
  NIVEAU_INDETERMINE = :indetermine
  APTE = :apte
  APTE_AVEC_AIDE = :apte_avec_aide

  PROFIL_4_PLUS_PLUS = :profil4_plus_plus
  PROFIL_4_PLUS = :profil4_plus
  PROFIL_4 = :profil4
  PROFIL_3 = :profil3
  PROFIL_2 = :profil2
  PROFIL_1 = :profil1
  PROFIL_ABERRANT = :profil_aberrant
  PROFIL_4H = :profil_4h
  PROFIL_4H_PLUS = :profil_4h_plus
  PROFIL_4H_PLUS_PLUS = :profil_4h_plus_plus

  PROFILS_BAS = [ PROFIL_1, PROFIL_2, PROFIL_3, PROFIL_4, PROFIL_4_PLUS, PROFIL_4_PLUS_PLUS ].freeze
  NIVEAUX = [ NIVEAU_INDETERMINE, NIVEAU_1, NIVEAU_2, NIVEAU_3, NIVEAU_4 ].freeze

  PERSEVERANCE = :perseverance
  COMPREHENSION_CONSIGNE = :comprehension_consigne
  RAPIDITE = :rapidite
  COMPARAISON_TRI = :comparaison_tri
  ATTENTION_CONCENTRATION = :attention_concentration
  ORGANISATION_METHODE = :organisation_methode
  VIGILANCE_CONTROLE = :vigilance_controle

  COMPETENCES_TRANSVERSALES = [
    RAPIDITE,
    COMPARAISON_TRI,
    ATTENTION_CONCENTRATION,
    ORGANISATION_METHODE,
    VIGILANCE_CONTROLE
  ].freeze

  VOCABULAIRE = :vocabulaire
end
