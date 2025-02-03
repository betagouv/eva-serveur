# frozen_string_literal: true

module ActiveAdmin
  module ActionsItemsSidebar
    module ResourceExtension
      ACTION_MAP = {
        'new' => :create,
        'edit' => :update,
        'destroy' => :destroy
      }.freeze

      def initialize(*)
        super
        add_action_items_sidebar
      end

      def actions_items_sidebar_section
        ActiveAdmin::SidebarSection.new :action_items, if: au_moins_une_action_autorisee,
                                                       class: 'action-items-sidebar' do
          insert_tag view_factory.action_items,
                     active_admin_config.action_items_for(params[:action], self)
        end
      end

      def au_moins_une_action_autorisee
        lambda {
          active_admin_config.action_items_for(params[:action], self).any? do |item|
            action = ACTION_MAP.fetch(item.name.to_s, :read)
            authorized?(action, active_admin_config.resource_class)
          end
        }
      end

      def add_action_items_sidebar
        sidebar_sections.prepend actions_items_sidebar_section
      end
    end
  end
end
