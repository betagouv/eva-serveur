module Comptes
  class ActivationStructure
    STATUTS = Structures::Activation::STATUTS

    def self.filtre(comptes, statut)
      return comptes unless STATUTS.include?(statut)

      comptes.where(structure: Structures::Activation.filtre(Structure.all, statut))
    end

    def self.nombres(comptes)
      STATUTS.index_with { |statut| filtre(comptes, statut).count }
    end
  end
end
