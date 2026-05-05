ActiveAdmin.register StructureOpco do
  menu parent: I18n.t(".menu_structure"), if: proc {
    current_compte.anlci? || current_compte.administratif?
  }

  filter :nom, filters: [ :contains_unaccent, :eq ]
  filter :created_at

  index dsfr_table: proc { true } do
    column :nom do |structure|
      link_to structure.nom, admin_structure_opco_path(structure)
    end
    column :created_at do |structure|
      l(structure.created_at, format: :sans_heure)
    end
    actions
  end
end
