# frozen_string_literal: true

module RuboCop
  module Cop
    module Dsfr
      # Fait respecter la distinction DSFR entre Lien et Bouton
      # (voir GLOSSARY.md et
      # https://www.systeme-de-design.gouv.fr/version-courante/fr/composants/lien).
      #
      # - Un lien écrit à la main (link_to, link_to_if, link_to_unless) ne porte pas
      #   la classe fr-btn : un Bouton passe par BoutonDsfrComponent.
      # - Un BoutonDsfrComponent dont le libellé désigne une consultation
      #   (voir, consulter, lire, détail) devrait être un Lien (LienComponent).
      #
      # Limites connues :
      # - le HTML brut des vues ERB (<a class="fr-btn">) n'est pas analysé ;
      # - dans un ERB, le libellé passé dans un bloc `do %>...<% end`
      #   est un fragment séparé de l'appel au composant : il n'est pas vérifié ;
      # - seul le dernier segment de la clé i18n est examiné : une clé générique
      #   comme `.action` n'est pas détectée.
      #
      # Pour un cas assumé, désactiver le cop avec une justification :
      #   # rubocop:disable Dsfr/LienStyleBouton -- appel à traiter les demandes
      #
      # @example
      #   # mauvais
      #   link_to "Jouer", url, class: "fr-btn"
      #   BoutonDsfrComponent.new(url, tag: :a).with_content(t(".voir_tout"))
      #
      #   # bon
      #   BoutonDsfrComponent.new(url, tag: :a).with_content(t(".jouer"))
      #   LienComponent.new(t(".voir_tout"), url)
      class LienStyleBouton < Base
        MSG_LIEN = "Un lien ne doit pas porter la classe `fr-btn` : utilisez " \
                   "`BoutonDsfrComponent` pour une action, ou `fr-link` pour une consultation."
        MSG_CONSULTATION = "Un bouton ne doit pas mener à un contenu à consulter : " \
                           "utilisez `LienComponent`."

        METHODES_LIEN = %i[link_to link_to_if link_to_unless].freeze
        RESTRICT_ON_SEND = (METHODES_LIEN + %i[with_content]).freeze

        CLASSE_BOUTON = /(?<![\w-])fr-btn(?![\w-])/
        LIBELLE_CONSULTATION = /\A(voir|consulter|lire|d[eé]tail)/i

        def_node_matcher :bouton_dsfr?, <<~PATTERN
          (send (const {nil? cbase} :BoutonDsfrComponent) :new ...)
        PATTERN

        def_node_matcher :traduction, <<~PATTERN
          (send {nil? (const {nil? cbase} :I18n)} {:t :translate} (str $_) ...)
        PATTERN

        def on_send(node)
          if METHODES_LIEN.include?(node.method_name)
            verifie_lien(node)
          else
            verifie_bouton(node)
          end
        end

        private

        def verifie_lien(node)
          return unless node.arguments.any? { |argument| classe_bouton?(argument) }

          add_offense(node, message: MSG_LIEN)
        end

        def classe_bouton?(argument)
          noeuds = [ argument, *argument.each_descendant(:pair) ]
          noeuds.select(&:pair_type?).any? do |paire|
            cle_class?(paire.key) && contient_classe_bouton?(paire.value)
          end
        end

        def cle_class?(cle)
          (cle.sym_type? || cle.str_type?) && cle.value.to_s == "class"
        end

        def contient_classe_bouton?(valeur)
          textes = valeur.str_type? ? [ valeur ] : valeur.each_descendant(:str).to_a
          textes.any? { |texte| texte.value.match?(CLASSE_BOUTON) }
        end

        def verifie_bouton(node)
          return unless node.receiver && bouton_dsfr?(node.receiver)

          libelle = libelle(node.first_argument)
          return unless libelle&.match?(LIBELLE_CONSULTATION)

          add_offense(node, message: MSG_CONSULTATION)
        end

        def libelle(argument)
          return if argument.nil?
          return argument.value.strip if argument.str_type?

          cle = traduction(argument)
          cle&.split(".")&.last
        end
      end
    end
  end
end
