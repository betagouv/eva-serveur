# frozen_string_literal: true

module FormatageSiretHelper
  SIRET_MAX_LENGTH = 14

  # Formate un SIRET en groupes 3-3-3-5 pour l'affichage utilisateur.
  # Accepte une saisie brute ou déjà partiellement formatée.
  def formater_siret(brut)
    return if brut.blank?
    chiffres = extraire_chiffres_siret(brut)
    return if chiffres.empty?

    [ chiffres[0, 3], chiffres[3, 3], chiffres[6, 3], chiffres[9, 5] ].compact_blank.join(" ")
  end

  def extraire_chiffres_siret(brut)
    brut.to_s.gsub(/\D/, "")[0, SIRET_MAX_LENGTH]
  end

  module_function :formater_siret, :extraire_chiffres_siret
end
