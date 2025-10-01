module Anonymisation
  class Campagne < Anonymisation::Base
    def anonymise
      super do |campagne|
        campagne.libelle = FFaker::Product.product_name
      end
    end
  end
end
