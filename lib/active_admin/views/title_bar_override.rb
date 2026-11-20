# Les action_items sont affichés dans l'encart de gestion de la barre latérale
# (voir ActiveAdmin::ActionsItemsSidebar) : on ne les génère plus dans la barre de titre.
#
# Une page sortie d'ActiveAdmin affiche son propre en-tête (EntetePageComponent) :
# son contrôleur pose @entete_page_dsfr et la barre de titre n'est pas générée (ADR 0004).

module ActiveAdmin
  module Views
    module TitleBarOverride
      def build(*)
        return if assigns[:entete_page_dsfr]

        super
      end

      private

      def build_titlebar_right; end
    end
  end
end

unless ActiveAdmin::Views::TitleBar.ancestors.include?(ActiveAdmin::Views::TitleBarOverride)
  ActiveAdmin::Views::TitleBar.prepend(ActiveAdmin::Views::TitleBarOverride)
end
