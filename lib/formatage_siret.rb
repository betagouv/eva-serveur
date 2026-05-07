# frozen_string_literal: true

module FormatageSiret
  SIRET_MAX_LENGTH = 14

  # Formate un SIRET en groupes 3-3-3-5 pour l'affichage utilisateur.
  # Accepte une saisie brute ou déjà partiellement formatée.
  def self.formater(brut)
    chiffres = extraire_chiffres(brut)
    return nil if chiffres.blank?

    [ chiffres[0, 3], chiffres[3, 3], chiffres[6, 3], chiffres[9, 5] ].compact_blank.join(" ")
  end

  def self.extraire_chiffres(brut)
    brut.to_s.gsub(/\D/, "")[0, SIRET_MAX_LENGTH]
  end
end
