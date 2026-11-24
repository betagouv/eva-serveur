# Les action_items sont affichés dans l'encart de gestion de la barre latérale
# (voir ActiveAdmin::ActionsItemsSidebar) : on ne les génère plus dans la barre de titre.

module ActiveAdmin
  module Views
    module TitleBarOverride
      # Une page déclarée avec l'option fil_ariane_dsfr (ex. `show fil_ariane_dsfr: proc { ... }`)
      # affiche ce fil d'Ariane DSFR à la place du fil d'Ariane et du titre d'ActiveAdmin,
      # au-dessus du contenu et de la barre latérale
      def build(title, action_items)
        liens = liens_fil_ariane_dsfr
        return super unless liens

        add_class "fil-ariane-dsfr"
        text_node(helpers.dsfr_breadcrumbs do |fil|
          liens.each { |libelle, url| fil.with_breadcrumb(label: libelle, href: url) }
        end)
      end

      private

      def liens_fil_ariane_dsfr
        presenter = active_admin_config.try(:get_page_presenter, controller.action_name)
        fil_ariane = presenter && presenter[:fil_ariane_dsfr]
        fil_ariane && instance_exec(&fil_ariane)
      end

      def build_titlebar_right; end
    end
  end
end

unless ActiveAdmin::Views::TitleBar.ancestors.include?(ActiveAdmin::Views::TitleBarOverride)
  ActiveAdmin::Views::TitleBar.prepend(ActiveAdmin::Views::TitleBarOverride)
end
