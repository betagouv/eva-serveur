# frozen_string_literal: true

module Restitution
  module Critere
    class Numeratie
      include ActiveModel::Model
      include ActiveModel::Attributes

      # Exemple : 2.1 doit avoir un score >= 75% pour être acquis
      RESULTATS = {
        '2.1': 75,
        '2.2': 50,
        '2.3': 75,
        '2.4': 100,
        '2.5': 66
      }.freeze

      CODE_CLEA_SANS_TEST = %w[2.1.5 2.1.6 2.3.6 2.5.1 2.5.2].freeze

      attribute :libelle, :string
      attribute :code_clea, :string
      attribute :nombre_tests_proposes, :integer
      attribute :nombre_tests_proposes_max, :integer
      attribute :pourcentage_reussite, :integer

      def acquis?
        minimum_pourcentage = RESULTATS[code_clea[0, 3].to_sym]
        return false if minimum_pourcentage.nil?
        return false if pourcentage_reussite.nil?

        pourcentage_reussite >= minimum_pourcentage
      end

      def resultat
        return :pas_de_test if CODE_CLEA_SANS_TEST.include?(code_clea)
        return :non_evalue if nombre_tests_proposes.zero?

        acquis? ? :acquis : :non_acquis
      end
    end
  end
end
