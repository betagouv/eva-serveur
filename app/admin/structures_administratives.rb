ActiveAdmin.register StructureAdministrative do
  menu parent: I18n.t(".menu_structure"), if: proc {
    current_compte.anlci? || current_compte.administratif?
  }

  permit_params :nom, :parent_id, :siret

  filter :nom
  filter :created_at

  index do
    column :nom do |sa|
      link_to sa.nom, admin_structure_administrative_path(sa)
    end
    column :created_at do |structure|
      l(structure.created_at, format: :sans_heure)
    end
    actions
  end

  show do
    render partial: "admin/structures/show", locals: { structure: resource }
  end

  form partial: "form"

  controller do
    before_action :trouve_campagnes, only: :show

    def trouve_campagnes
      @campagnes = Campagne.de_la_structure(resource)
    end

    def statistiques_structure
      StatistiquesStructure.new(resource).nombre_evaluations_des_12_derniers_mois
    end
  end
end
