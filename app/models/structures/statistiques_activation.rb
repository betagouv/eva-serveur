module Structures
  class StatistiquesActivation
    def initialize(activation, actif:, statut:)
      @activation = activation
      @actif = actif
      @statut = statut
    end

    def actif?
      @actif
    end

    def statut
      @statut if actif?
    end

    def applique(liste)
      @liste_avant_activation = liste
      actif? ? @activation.filtre(liste, @statut) : liste
    end

    def nombres
      @activation.nombres(@liste_avant_activation)
    end
  end
end
