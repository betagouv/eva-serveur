module Restitution
  module SousCompetence
    class Litteratie
      LISTE = [ :lecture, :comprehension, :production ]

      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :profil, :string
    end
  end
end
