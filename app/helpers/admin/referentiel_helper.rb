module Admin
  module ReferentielHelper
    def actions_referentiel(modele, *actions_supplementaires)
      route = modele.model_name.singular_route_key
      [
        { label: t("active_admin.view"), type: :read, url: :"admin_#{route}_path" },
        { label: t("active_admin.edit"), type: :edit, url: :"edit_admin_#{route}_path" },
        *actions_supplementaires,
        { label: t("active_admin.delete"), type: :destroy, url: :"admin_#{route}_path",
          method: :delete, data: { confirm: t("active_admin.delete_confirmation") } }
      ]
    end
  end
end
