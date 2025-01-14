# frozen_string_literal: true

module Restitution
  module SousCompetence
    class Numeratie
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :succes, :boolean
      attribute :pourcentage_reussite, :integer
      attribute :nombre_questions_repondues, :integer
      attribute :nombre_total_questions, :integer
    end
  end
end
