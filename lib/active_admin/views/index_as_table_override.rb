# frozen_string_literal: true

module ActiveAdmin
  module Views
    module IndexAsTableOverride
      def build(page_presenter, collection)
        eva_pro_presenter = page_presenter[:evapro]
        use_evapro = eva_pro_presenter && instance_exec(&eva_pro_presenter)

        if use_evapro
          table_options = {
            id: "index_table_#{active_admin_config.resource_name.plural}",
            sortable: true,
            class: "index_table index ma_classe",
            i18n: active_admin_config.resource_class,
            paginator: page_presenter[:paginator] != false,
            row_class: page_presenter[:row_class]
          }

          table_for collection, table_options do |t|
            table_config_block = page_presenter.block || default_table
            instance_exec(t, &table_config_block)
          end
        else
          super
        end
      end
    end
  end
end

unless ActiveAdmin::Views::IndexAsTable.ancestors.include?(ActiveAdmin::Views::IndexAsTableOverride)
  ActiveAdmin::Views::IndexAsTable.prepend(ActiveAdmin::Views::IndexAsTableOverride)
end
