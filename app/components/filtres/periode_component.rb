module Filtres
  class PeriodeComponent < ViewComponent::Base
    def initialize(champ:, libelle:, debut: nil, fin: nil)
      @champ = champ
      @libelle = libelle
      @bornes = [
        [ "#{champ}_gteq_datetime", I18n.t("admin.date_depuis"), debut, :tag_debut ],
        [ "#{champ}_lteq_datetime", I18n.t("admin.date_jusqua"), fin, :tag_fin ]
      ]
    end

    def tags
      @bornes.select { |_predicat, _libelle, valeur, _cle| valeur.present? }
             .map do |predicat, _libelle, valeur, cle|
        Tag.new(libelle: I18n.t(cle, scope: "components.filtres", libelle: @libelle,
                                     date: date_lisible(valeur)),
                nom: "q[#{predicat}]", valeur: valeur)
      end
    end

    private

    def date_lisible(valeur)
      I18n.l(Date.iso8601(valeur.to_s))
    rescue Date::Error
      valeur
    end
  end
end
