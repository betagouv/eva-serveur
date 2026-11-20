module CompteHelper
  def actions_compte
    [
      { label: t("admin.comptes.index.voir"), type: :read, url: :admin_compte_path },
      { label: t("admin.comptes.index.modifier"), type: :edit, url: :edit_admin_compte_path },
      { label: t("admin.comptes.index.supprimer"), type: :destroy,
        url: :admin_compte_path, method: :delete,
        data: { confirm: t("admin.comptes.index.confirmation_suppression") } }
    ]
  end

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
