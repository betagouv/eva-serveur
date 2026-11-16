module Anonymisation
  class Structure < Anonymisation::Base
    def anonymise
      super do |structure|
        structure.code_postal ||= ::StructureLocale::VALEUR_NON_COMMUNIQUEE
        structure.siret = nil
        structure.nom = FFaker::Company.name
      end
    end
  end
end
