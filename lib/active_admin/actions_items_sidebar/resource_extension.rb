module ActiveAdmin
  module ActionsItemsSidebar
    module ResourceExtension
      ACTION_MAP = {
        "new" => :create,
        "edit" => :update,
        "destroy" => :destroy
      }.freeze

      def initialize(*)
        super
        add_action_items_sidebar
      end

      def actions_items_sidebar_section
        extension = self
        ActiveAdmin::SidebarSection.new :action_items,
          if: lambda { extension.au_moins_une_action_autorisee(self) },
          class: "action-items-sidebar" do
          insert_tag view_factory.action_items,
                     active_admin_config.action_items_for(params[:action], self)
        end
      end

      def au_moins_une_action_autorisee(contexte_vue)
        contexte_vue.active_admin_config
                   .action_items_for(contexte_vue.params[:action], contexte_vue).any? do |item|
          action = ACTION_MAP.fetch(item.name.to_s, :read)
          action_autorisee?(action, contexte_vue)
        end
      end

      private

      def action_autorisee?(action, contexte_vue)
        begin
            resource = contexte_vue.resource
            resource.present? && contexte_vue.authorized?(action, resource)
        rescue ActiveRecord::RecordNotFound
          contexte_vue.authorized?(action, contexte_vue.active_admin_config.resource_class)
        end
      end

      def add_action_items_sidebar
        sidebar_sections.prepend actions_items_sidebar_section
      end
    end
  end
end
