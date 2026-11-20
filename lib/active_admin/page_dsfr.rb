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
  ActiveAdmin::Views::TitleBar => ActiveAdmin::PageDsfr::BarreDeTitre
}.each do |classe, extension|
  classe.prepend(extension) unless classe.ancestors.include?(extension)
end
