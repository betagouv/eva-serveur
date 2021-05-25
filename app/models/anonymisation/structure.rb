# frozen_string_literal: true

module Anonymisation
  class Structure < Anonymisation::Base
    def anonymise
      super do |structure|
        structure.code_postal = 'Non communiqué' if structure.code_postal.nil?
        structure.nom = FFaker::Company.name
      end
    end
  end
end
