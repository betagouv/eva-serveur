# On ne va faire de validation de l'algo de Luhn
# On fera une vérification plus tard avec un point d'api
# La poste ne respecte pas l'algo de luhn pour son siret
module ValidationSiret
  extend ActiveSupport::Concern

  included do
    class_attribute :validation_siret_column_name, default: :siret, instance_predicate: false

    before_validation :normalize_siret
  end

  class_methods do
    # Configure la colonne à valider (:siret par défaut, ou :siret_pro_connect par ex.)
    # Usage : validation_siret_column :siret_pro_connect
    def validation_siret_column(column = nil)
      if column.nil?
        validation_siret_column_name
      else
        self.validation_siret_column_name = column.to_sym
      end
    end
  end

  private

  def siret_column
    self.class.validation_siret_column
  end

  def normalize_siret
    valeur_siret = send(siret_column)
    return if valeur_siret.blank?

    send("#{siret_column}=", valeur_siret.to_s.gsub(/\s+/, ""))
  end

  def validation_siret
    valeur_siret = send(siret_column)
    return true if valeur_siret.blank?

    if !siret_contient_seulement_des_chiffres?
      errors.add(siret_column, :invalid)
      return false
    end
    return true if valeur_siret.size == 14

    errors.add(siret_column, :invalid)
    false
  end

  def validation_siret_ou_siren
    valeur_siret = send(siret_column)
    return true if valeur_siret.blank?

    if !siret_contient_seulement_des_chiffres?
      errors.add(siret_column, :invalid)
      return false
    end
    return true if valeur_siret.size == 9 || valeur_siret.size == 14

    errors.add(siret_column, :invalid)
    false
  end

  def siret_contient_seulement_des_chiffres?
    send(siret_column).match?(/\A\d+\z/)
  end
end
