# frozen_string_literal: true

module CompteHelper
  def traduis_acces(statut_validation, role)
    statut = Compte.human_enum_name(:statut_validation, statut_validation)
    role = " - #{Compte.human_enum_name(:role, role)}" if role.present?
    "#{statut}#{role}"
  end
end
