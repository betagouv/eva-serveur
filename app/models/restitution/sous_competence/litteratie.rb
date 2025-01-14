# frozen_string_literal: true

module Restitution
  module SousCompetence
    class Litteratie
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :profil, :string
    end
  end
end
