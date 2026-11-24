module Filtres
  class Choix
    def initialize(parametres, champ, modele)
      @parametres = parametres
      @champ = champ
      @modele = modele
    end

    def id
      @parametres[@champ]
    end

    def enregistrement
      return if id.blank?

      @enregistrement ||= @modele.find_by(id: id)
    end

    def libelle
      enregistrement&.display_name
    end
  end
end
