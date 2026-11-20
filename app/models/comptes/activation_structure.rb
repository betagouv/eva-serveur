module Comptes
  class ActivationStructure
    STATUTS = %w[sans_campagne pas_vraiment_utilisatrices non_activees actives inactives
                 abandonnistes].freeze

    def self.filtre(comptes, statut)
      return comptes unless STATUTS.include?(statut)

      comptes.where(structure: Structure.public_send(statut))
    end

    def self.nombres(comptes)
      STATUTS.index_with { |statut| filtre(comptes, statut).count }
    end
  end
end
