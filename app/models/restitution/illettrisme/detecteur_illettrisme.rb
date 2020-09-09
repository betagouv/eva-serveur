# frozen_string_literal: true

module Restitution
  module Illettrisme
    class DetecteurIllettrisme
      COMPETENCES_UTILES = %w[ccf syntaxe_orthographe].freeze

      def initialize(restitutions)
        @restitutions = restitutions
      end

      def illettrisme_potentiel?
        pourcentage = compte_reponses(:nombre_bonnes_reponses)
                      .fdiv(compte_reponses(:nombre_reponses))
        pourcentage < 0.8
      end

      private

      def compte_reponses(prefixe)
        restitutions_teminees.inject(0) do |n, restitution|
          n + compte_pour_une_restitution(prefixe, restitution)
        end
      end

      def compte_pour_une_restitution(prefixe, restitution)
        metriques = restitution.partie.metriques
        COMPETENCES_UTILES.inject(0) do |n, competence|
          n + (metriques["#{prefixe}_#{competence}"] || 0)
        end
      end

      def restitutions_teminees
        @restitutions_teminees ||= @restitutions.select(&:termine?)
      end
    end
  end
end
