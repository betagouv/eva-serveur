# frozen_string_literal: true

module QuestionData
  class Base < StaticRecord::Base
    self.chemin_data = 'questions/*.yml'

    attr_reader :nom_technique, :score, :metacompetence

    def initialize(attributes = {})
      super()
      @nom_technique = attributes['nom_technique']
      @score = attributes['score']
      @metacompetence = attributes['metacompetence']
    end
  end
end
