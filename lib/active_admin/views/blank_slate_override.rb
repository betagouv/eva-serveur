# Permet d'overrider le blank slate d'ActiveAdmin pour l'espace Evapro.
# Si aucun titre n'est fourni, on tombe sur le comportement standard.

module ActiveAdmin
  module Views
    module BlankSlateOverride
      def default_class_name
        "blank_slate_container"
      end

      def build(content)
        return super(span(content.html_safe, class: "blank_slate")) unless utilisateur_evapro?

        resource_key = active_admin_config.resource_name.plural
        titre, sous_titre, texte = blank_slate_texts(resource_key)

        # Si pas de titre, fallback sur le comportement standard
        return super(span(content.html_safe, class: "blank_slate")) if titre.blank?

        build_custom_blank_slate(titre, sous_titre, texte)
      end

      private

      def utilisateur_evapro?
        controller.respond_to?(:current_compte) &&
          controller.current_compte&.utilisateur_entreprise?
      end

      def blank_slate_texts(resource_key)
        [
          I18n.t("admin.#{resource_key}.blank_slate.titre", default: ""),
          I18n.t("admin.#{resource_key}.blank_slate.sous_titre", default: ""),
          I18n.t("admin.#{resource_key}.blank_slate.texte", default: "")
        ]
      end

      def build_custom_blank_slate(titre, sous_titre, texte)
        div class: "blank_slate_custom" do
          h2 class: "blank_slate_custom__titre" do
            titre
          end
          div class: "blank_slate_custom__sous-titre" do
            sous_titre unless sous_titre.blank?
          end
          div class: "blank_slate_custom__texte" do
            texte unless texte.blank?
          end
        end
      end
    end
  end
end

# prepend si ce n'est pas déjà fait
unless ActiveAdmin::Views::BlankSlate.ancestors.include?(ActiveAdmin::Views::BlankSlateOverride)
  ActiveAdmin::Views::BlankSlate.prepend(ActiveAdmin::Views::BlankSlateOverride)
end
