module Restitution
  module Critere
    class Numeratie
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :libelle, :string
      attribute :code_clea, :string
      attribute :nombre_tests_proposes, :integer
      attribute :nombre_tests_proposes_max, :integer
      attribute :pourcentage_reussite, :integer
    end
  end
end
