# Une liste dont le contenu est sorti d'ActiveAdmin (ADR 0004) est une vue ERB placée dans
# app/views/admin/<ressource>/. Son contrôleur pose @page_dsfr : ActiveAdmin l'encadre alors
# de son layout, avec sa barre de titre et sa sidebar (gestion, filtres), comme ses propres
# pages.

module ActiveAdmin
  module PageDsfr
    module Controleur
      private

      def determine_active_admin_layout
        @page_dsfr ? "active_admin" : super
      end
    end

    # Dans ActiveAdmin.register : la liste est rendue par la vue ERB de la ressource.
    module Dsl
      def liste_dsfr
        controller do
          before_action(only: :index) do
            @page_title = active_admin_config.plural_resource_label
            @page_dsfr = true
          end
        end
      end
    end
  end
end

ActiveSupport.on_load(:active_admin_controller) do
  prepend ActiveAdmin::PageDsfr::Controleur if self == ActiveAdmin::BaseController
end

unless ActiveAdmin::ResourceDSL.ancestors.include?(ActiveAdmin::PageDsfr::Dsl)
  ActiveAdmin::ResourceDSL.prepend(ActiveAdmin::PageDsfr::Dsl)
end
