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
        add_action_item_telechargement_xls
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

      def telechargement_xls_disponible?(contexte_vue)
        presenter_index = get_page_presenter(:index) || {}
        liens = presenter_index.fetch(:download_links, namespace.download_links)
        liens = contexte_vue.instance_exec(&liens) if liens.is_a?(Proc)
        formats_telechargement(liens).include?(:xls)
      end

      private

      # Reproduit ActiveAdmin::ViewHelpers::DownloadFormatLinksHelper#build_download_formats,
      # qui est privé.
      def formats_telechargement(liens)
        if liens.is_a?(Array) && liens.any?
          liens
        elsif liens == false
          []
        else
          ActiveAdmin::Views::PaginatedCollection.formats
        end
      end

      def add_action_item_telechargement_xls
        extension = self
        add_action_item :telechargement_xls, only: :index, priority: 100,
                        if: -> { extension.telechargement_xls_disponible?(self) } do
          parametres = request.query_parameters.except(:format, :commit)
          render BoutonDsfrComponent.new(
            url_for(params: parametres, format: :xls),
            tag: :telechargement,
            type: :secondary,
            size: :sm,
            title: I18n.t("active_admin.action_items.telechargement_xls.titre")
          ).with_content(I18n.t("active_admin.action_items.telechargement_xls.libelle"))
        end
      end

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
