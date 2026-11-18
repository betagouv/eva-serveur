# frozen_string_literal: true

module RuboCop
  module Cop
    module Dsfr
      # Le DSFR réserve le bouton tertiaire aux actions contextuelles comme
      # "copier un lien" :
      # https://www.systeme-de-design.gouv.fr/version-courante/fr/composants/bouton#comment-utiliser-ce-composant
      #
      # Signale un BoutonDsfrComponent ou un button_tag dont le libellé commence
      # par "copier" et qui n'est pas tertiaire. BoutonCopierComponent est
      # tertiaire par construction.
      #
      # Limites connues : celles de Dsfr/LienStyleBouton (HTML brut des ERB,
      # libellé passé en bloc, seul le dernier segment de la clé i18n examiné).
      #
      # @example
      #   # mauvais
      #   BoutonDsfrComponent.new(url, tag: :button).with_content(t(".copier_code"))
      #   button_tag "Copier", class: "fr-btn fr-btn--secondary"
      #
      #   # bon
      #   BoutonDsfrComponent.new(url, tag: :button, type: :tertiary)
      #                      .with_content(t(".copier_code"))
      #   BoutonCopierComponent.new(libelle: t(".copier_code"), texte: code)
      class BoutonCopierTertiaire < Base
        MSG = "Un bouton « Copier… » doit être tertiaire (`type: :tertiary`)."

        RESTRICT_ON_SEND = %i[with_content button_tag].freeze

        LIBELLE_COPIER = /\Acopier/i
        TYPES_TERTIAIRES = %i[tertiary tertiary_no_outline].freeze
        CLASSE_TERTIAIRE = /(?<![\w-])fr-btn--tertiary(-no-outline)?(?![\w-])/

        def_node_matcher :bouton_dsfr?, <<~PATTERN
          (send (const {nil? cbase} :BoutonDsfrComponent) :new ...)
        PATTERN

        def_node_matcher :traduction, <<~PATTERN
          (send {nil? (const {nil? cbase} :I18n)} {:t :translate} (str $_) ...)
        PATTERN

        def on_send(node)
          if node.method?(:button_tag)
            verifie_button_tag(node)
          elsif node.receiver && bouton_dsfr?(node.receiver)
            verifie_bouton_dsfr(node)
          end
        end

        private

        def verifie_bouton_dsfr(node)
          return unless copier?(node.first_argument)
          return if TYPES_TERTIAIRES.include?(valeur_option(node.receiver, :type))

          add_offense(node)
        end

        def verifie_button_tag(node)
          return unless copier?(node.first_argument)

          classe = valeur_option(node, :class)
          return if classe.is_a?(String) && classe.match?(CLASSE_TERTIAIRE)

          add_offense(node)
        end

        def valeur_option(node, nom)
          options = node.last_argument
          return unless options&.hash_type?

          paire = options.pairs.find do |p|
            p.key.respond_to?(:value) && p.key.value.to_s == nom.to_s
          end
          paire&.value&.value if paire&.value.respond_to?(:value)
        end

        def copier?(argument)
          libelle(argument)&.match?(LIBELLE_COPIER)
        end

        def libelle(argument)
          return if argument.nil?
          return argument.value.strip if argument.str_type?

          traduction(argument)&.split(".")&.last
        end
      end
    end
  end
end
