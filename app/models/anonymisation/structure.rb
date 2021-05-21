# frozen_string_literal: true

module Anonymisation
  class Structure < Anonymisation::Base
    def anonymise
      super do |structure|
        structure.nom = FFaker::Company.name
      end
    end
  end
end
