module CompteHelper
  def traduis_acces(statut_validation, role)
    statut_humain = Compte.human_enum_name(:statut_validation, statut_validation)
    if statut_validation == "acceptee"
      role_humain = Compte.human_enum_name(:role, role)
      "#{statut_humain} - #{role_humain}"
    else
      "#{statut_humain}"
    end
  end
end
