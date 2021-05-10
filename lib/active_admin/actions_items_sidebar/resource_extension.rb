# frozen_string_literal: true

module ActiveAdmin
  module ActionsItemsSidebar
    module ResourceExtension
      def initialize(*)
        super
        add_action_items_sidebar
      end

      def actions_items_sidebar_section
        displayable = -> { active_admin_config.action_items_for(params[:action], self).any? }
        ActiveAdmin::SidebarSection.new :action_items, if: displayable, class: 'annule-panel' do
          insert_tag view_factory.action_items,
                     active_admin_config.action_items_for(params[:action], self)
        end
      end

      def add_action_items_sidebar
        sidebar_sections.prepend actions_items_sidebar_section
      end
    end
  end
end
