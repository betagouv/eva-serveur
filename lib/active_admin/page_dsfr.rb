# Une liste dont le contenu est sorti d'ActiveAdmin (ADR 0004) est une vue ERB placée dans
# app/views/admin/<ressource>/. Son contrôleur pose @page_dsfr : ActiveAdmin l'encadre alors
# de son layout. Quand la liste rend aussi son en-tête et ses filtres DSFR (@entete_dsfr),
# ActiveAdmin n'affiche ni sa barre de titre ni sa sidebar.

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
        assigns[:entete_dsfr] == true || super
      end
    end

    # Dans ActiveAdmin.register : la liste est rendue par la vue ERB de la ressource. Avec un
    # bloc, ses filtres sont rendus par la vue et lus par l'objet que construit le bloc à
    # partir de params[:q].
    module Dsl
      def liste_dsfr(&filtres)
        if filtres
          config.filters = false
          config.current_filters = false
        end
        controller do
          # Pour les compteurs des scopes (admin/_scopes), comme dans le template d'index d'AA
          helper_method :collection_before_scope

          before_action(only: :index) do
            @page_title = active_admin_config.plural_resource_label
            @page_dsfr = true
            next unless filtres

            @entete_dsfr = true
            @filtres = instance_exec(params[:q], &filtres)
          end
        end
      end
    end

    module BarreDeTitre
      def build(*)
        return if assigns[:entete_dsfr]

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
