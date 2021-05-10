require 'active_admin/actions_items_sidebar/resource_extension'

ActiveAdmin::Resource.send :include, ActiveAdmin::ActionsItemsSidebar::ResourceExtension
