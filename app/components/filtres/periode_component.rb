module Filtres
  class PeriodeComponent < ViewComponent::Base
    def initialize(champ:, libelle:, debut: nil, fin: nil)
      @champ = champ
      @libelle = libelle
      @bornes = [
        [ "#{champ}_gteq_datetime", I18n.t("admin.date_depuis"), debut ],
        [ "#{champ}_lteq_datetime", I18n.t("admin.date_jusqua"), fin ]
      ]
    end
  end
end
