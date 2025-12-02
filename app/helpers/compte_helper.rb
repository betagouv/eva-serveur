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

  def traduction_fonction(fonction)
    I18n.t(
      "activerecord.attributes.compte.fonctions.#{fonction}"
    )
  end

  def collection_fonctions
    Compte::FONCTIONS.map do |fonction|
      [ traduction_fonction(fonction), fonction ]
    end
  end
end
