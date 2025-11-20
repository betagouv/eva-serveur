# Support pour le tri insensible à la casse dans ActiveAdmin
# Usage: column :name, sortable: 'lower_table.column'
# Le préfixe 'lower_' déclenche un tri avec LOWER() en SQL

module ActiveAdminLowerSorting
  ORDER_PARAM_REGEX = /\Alower_([\w\_\.]+)_(desc|asc)\z/
end

Rails.application.config.to_prepare do
  ActiveAdmin::ResourceController.class_eval do
    def apply_sorting(chain)
      params[:order] ||= active_admin_config.sort_order

      if params[:order] && params[:order] =~ ActiveAdminLowerSorting::ORDER_PARAM_REGEX
        column = $1
        order = $2

        chain.reorder(Arel.sql("LOWER(#{column}) #{order.upcase}"))
      else
        super
      end
    end
  end
end
