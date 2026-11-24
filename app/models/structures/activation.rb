module Structures
  class Activation
    STATUTS = %w[sans_campagne pas_vraiment_utilisatrices non_activees actives inactives
                 abandonnistes].freeze

    def self.filtre(structures, statut)
      return structures unless STATUTS.include?(statut)

      structures.public_send(statut)
    end

    def self.options(nombres)
      STATUTS.map do |statut|
        [ "#{I18n.t("active_admin.scopes.#{statut}")} (#{nombres[statut]})", statut ]
      end
    end

    def self.nombres(structures)
      STATUTS.index_with { |statut| taille(filtre(structures, statut)) }
    end

    # Une liste groupée (nombre d'évaluations par structure) se compte par groupe
    def self.taille(structures)
      sans_tri = structures.except(:select, :order)
      sans_tri.group_values.any? ? sans_tri.count.size : sans_tri.count
    end
  end
end
