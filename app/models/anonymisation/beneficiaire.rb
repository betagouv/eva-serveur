module Anonymisation
  class Beneficiaire < Anonymisation::Base
    def anonymise
      super do |beneficiaire|
        beneficiaire.nom = FFaker::NameFR.name
      end
    end
  end
end
