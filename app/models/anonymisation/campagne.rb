# frozen_string_literal: true

module Anonymisation
  class Campagne < Anonymisation::Base
    def anonymise
      super do |campagne|
        campagne.libelle = FFaker::Product.product_name
        campagne.code = nil
      end
    end
  end
end
