# frozen_string_literal: true

class PasswordValidator < ActiveModel::Validator
  def validate(compte)
    value = compte.password
    return if value.blank?
    if compte.anlci?
      unless PasswordValidator.est_avec_12_maj_min_num_et_symbol?(value)
        compte.errors.add(:password, I18n.t(".creation_compte.regles_mot_de_passe_anlci"))
      end
    else
      if value.length < 8
        compte.errors.add(
          :password, I18n.t(".creation_compte.regles_mot_de_passe", longueur_mot_de_passe: 8))
      end
    end
  end

  def self.est_avec_12_maj_min_num_et_symbol?(value)
    value.length >= 12 &&
      value =~ /[A-Z]/ &&
      value =~ /[a-z]/ &&
      value =~ /[0-9]/ &&
      value =~ /[^A-Za-z0-9]/
  end
end
