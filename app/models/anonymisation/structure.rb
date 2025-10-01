module Anonymisation
  class Structure < Anonymisation::Base
    def anonymise
      super do |structure|
        structure.code_postal = ::StructureLocale::TYPE_NON_COMMUNIQUE if structure.code_postal.nil?
        structure.nom = FFaker::Company.name
      end
    end
  end
end
