# frozen_string_literal: true

module FormatageNumeroTelephone
  # Formate un numéro français en (+33) X XX XX XX XX à partir de chiffres bruts.
  # Accepte 0122334455, +33122334455, (+33)122334455, etc.
  # Ne formate pas 9 chiffres commençant par 0 (saisie incomplète 0 + 8 chiffres).
  def self.formater(brut)
    chiffres = extraire_chiffres(brut)
    return nil if chiffres.blank?
    return chiffres if saisie_incomplete?(chiffres)

    numero_national = extraire_numero_national(chiffres)
    return nil if numero_national.blank? || numero_national.size < 9

    afficher_francais(numero_national)
  end

  def self.saisie_incomplete?(chiffres)
    return true if chiffres.size == 9 && chiffres.start_with?("0")
    return true if chiffres.size >= 2 && chiffres.size < 11 && chiffres.start_with?("33")

    false
  end

  def self.extraire_chiffres(brut)
    brut.to_s.gsub(/\D/, "")
  end

  def self.extraire_numero_national(chiffres)
    return chiffres[2, 9] if chiffres.size >= 11 && chiffres.start_with?("33")
    return chiffres[1, 9] if chiffres.size >= 10 && chiffres.start_with?("0")
    return chiffres if chiffres.size == 9

    chiffres[0, 9]
  end

  def self.afficher_francais(numero_national)
    [
      "(+33)",
      numero_national[0],
      numero_national[1, 2],
      numero_national[3, 2],
      numero_national[5, 2],
      numero_national[7, 2]
    ].join(" ")
  end
end
