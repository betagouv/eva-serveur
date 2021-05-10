module ActiveAdmin
  module ActionsItemsSidebar
    module ResourceExtension
      def initialize(*)
        super
        add_action_items_sidebar
      end

      def actions_items_sidebar_section
        ActiveAdmin::SidebarSection.new :action_items, if: -> { active_admin_config.action_items_for(params[:action], self).any? } do
          insert_tag(view_factory.action_items, active_admin_config.action_items_for(params[:action], self))
        end
      end

      def add_action_items_sidebar
        self.sidebar_sections.prepend actions_items_sidebar_section
      end
    end
  end
end
