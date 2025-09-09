# frozen_string_literal: true

module Restitution
  module SousCompetence
    class Numeratie
      LISTE = [ :"2_1", :"2_2", :"2_3", :"2_4", :"2_5" ]

      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :succes, :boolean
      attribute :pourcentage_reussite, :integer
      attribute :nombre_questions_repondues, :integer
      attribute :nombre_total_questions, :integer
      attribute :criteres, array: true, default: -> { [] }
      attribute :nombre_questions_reussies, :integer
      attribute :nombre_questions_echecs, :integer
      attribute :nombre_questions_non_passees, :integer
    end
  end
end
