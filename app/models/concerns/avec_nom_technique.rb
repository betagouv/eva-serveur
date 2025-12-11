module AvecNomTechnique
  extend ActiveSupport::Concern

  included do
    validates :nom_technique, presence: true, uniqueness: true

    scope :par_nom_technique, ->(nom_technique) {
 where("nom_technique LIKE ?", "#{extraie_nom_technique_sans_variant(nom_technique)}%") }

    def self.extraie_nom_technique_sans_variant(nom_technique)
      nom_technique.split("__").first
    end

    def nom_technique_sans_variant
      self.class.extraie_nom_technique_sans_variant(nom_technique)
    end

    def a_pour_nom_technique?(nom_technique)
      nom_technique_sans_variant == self.class.extraie_nom_technique_sans_variant(nom_technique)
    end
  end
end
