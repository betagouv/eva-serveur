# frozen_string_literal: true

class PasswordValidator < ActiveModel::Validator
  def validate(compte)
    valeur = compte.password
    return if valeur.blank?

    valide_robustesse(compte, valeur)
    valide_different_email(compte, valeur)
  end

  def valide_different_email(compte, valeur)
    if valeur.strip.casecmp?(compte.email&.strip)
      compte.errors.add(
        :password, I18n.t(".creation_compte.mot_de_passe_email"))
    end
  end

  def valide_robustesse(compte, valeur)
    if compte.anlci?
      unless PasswordValidator.est_avec_12_maj_min_num_et_symbol?(valeur)
        compte.errors.add(:password, I18n.t(".creation_compte.regles_mot_de_passe_anlci"))
      end
    else
      if valeur.length < 8
        compte.errors.add(
          :password, I18n.t(".creation_compte.regles_mot_de_passe", longueur_mot_de_passe: 8))
      end
    end
  end

  def self.est_avec_12_maj_min_num_et_symbol?(valeur)
    valeur.length >= 12 &&
      valeur =~ /[A-Z]/ &&
      valeur =~ /[a-z]/ &&
      valeur =~ /[0-9]/ &&
      valeur =~ /[^A-Za-z0-9]/
  end
end
