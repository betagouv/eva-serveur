# Les action_items sont affichés dans l'encart de gestion de la barre latérale
# (voir ActiveAdmin::ActionsItemsSidebar) : on ne les génère plus dans la barre de titre.

module ActiveAdmin
  module Views
    module TitleBarOverride
      private

      def build_titlebar_right; end
    end
  end
end

unless ActiveAdmin::Views::TitleBar.ancestors.include?(ActiveAdmin::Views::TitleBarOverride)
  ActiveAdmin::Views::TitleBar.prepend(ActiveAdmin::Views::TitleBarOverride)
end
