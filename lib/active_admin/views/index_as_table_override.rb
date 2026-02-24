# frozen_string_literal: true

module ActiveAdmin
  module Views
    module IndexAsTableOverride
      def build(page_presenter, collection)
        eva_pro_presenter = page_presenter[:compte_evapro]
        presenter_compte_evapro = eva_pro_presenter && instance_exec(&eva_pro_presenter)

        return super unless presenter_compte_evapro

        div class: wrapper_classes(page_presenter), data: { fr_js_table: true } do
          nested_div("fr-table__wrapper") do
            nested_div("fr-table__container") do
              nested_div("fr-table__content") do
                build_table(collection, page_presenter)
              end
            end
          end
        end
      end

      private

      def wrapper_classes(page_presenter)
        [
          "fr-table",
          "fr-table--no-caption",
          "fr-m-0",
          "dsfr-table-active-admin",
          page_presenter[:class]
        ].compact.join(" ")
      end

      def table_options(page_presenter, table_dom_id)
        {
          id: table_dom_id,
          sortable: true,
          class: "index_table index",
          i18n: active_admin_config.resource_class,
          paginator: page_presenter[:paginator] != false,
          row_class: page_presenter[:row_class]
        }
      end

      def build_table(collection, page_presenter)
        table_for collection, table_options(page_presenter, "table-0") do |t|
          table_config_block = page_presenter.block || default_table
          instance_exec(t, &table_config_block)
        end
      end

      def nested_div(classes, &block)
        div class: classes, &block
      end
    end
  end
end

unless ActiveAdmin::Views::IndexAsTable.ancestors.include?(ActiveAdmin::Views::IndexAsTableOverride)
  ActiveAdmin::Views::IndexAsTable.prepend(ActiveAdmin::Views::IndexAsTableOverride)
end
