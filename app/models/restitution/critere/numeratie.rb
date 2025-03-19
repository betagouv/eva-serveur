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
      attribute :nombre_questions_reussies, :integer
      attribute :nombre_questions_echecs, :integer
      attribute :nombre_questions_non_passees, :integer

      def acquis?
        minimum_pourcentage = RESULTATS[code_clea[0, 3].to_sym]
        return false if minimum_pourcentage.nil?
        return false if pourcentage_reussite.nil?

        pourcentage_reussite >= minimum_pourcentage
      end

      def resultat
        return :pas_de_test if pas_de_test?
        return :non_evalue if non_evalue?

        acquis? ? :acquis : :non_acquis
      end

      def pas_de_test?
        CODE_CLEA_SANS_TEST.include?(code_clea)
      end

      def non_evalue?
        nombre_tests_proposes.zero?
      end
    end
  end
end
