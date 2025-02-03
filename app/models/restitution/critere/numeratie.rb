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
    end
  end
end
