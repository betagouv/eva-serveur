# Une page sortie d'ActiveAdmin (ADR 0004) est une vue ERB qui affiche son propre en-tête
# DSFR. Son contrôleur pose @page_dsfr : ActiveAdmin l'encadre alors de son layout, comme
# une action personnalisée, sans sa barre de titre ni sa sidebar.

module ActiveAdmin
  module PageDsfr
    module Controleur
      private

      def determine_active_admin_layout
        @page_dsfr ? "active_admin" : super
      end
    end

    module Page
      def skip_sidebar?
        assigns[:page_dsfr] == true || super
      end
    end

    # Dans ActiveAdmin.register : la liste devient une page DSFR, ses filtres sont rendus
    # par la vue et lus par l'objet que construit le bloc à partir de params[:q].
    module Dsl
      def liste_dsfr(&filtres)
        config.filters = false
        config.current_filters = false
        controller do
          before_action(only: :index) do
            @page_title = active_admin_config.plural_resource_label
            @page_dsfr = true
            @filtres = instance_exec(params[:q], &filtres)
          end
        end
      end
    end

    module BarreDeTitre
      def build(*)
        return if assigns[:page_dsfr]

        super
      end
    end
  end
end

ActiveSupport.on_load(:active_admin_controller) do
  prepend ActiveAdmin::PageDsfr::Controleur if self == ActiveAdmin::BaseController
end

{
  ActiveAdmin::Views::Pages::Base => ActiveAdmin::PageDsfr::Page,
  ActiveAdmin::Views::TitleBar => ActiveAdmin::PageDsfr::BarreDeTitre,
  ActiveAdmin::ResourceDSL => ActiveAdmin::PageDsfr::Dsl
}.each do |classe, extension|
  classe.prepend(extension) unless classe.ancestors.include?(extension)
end
