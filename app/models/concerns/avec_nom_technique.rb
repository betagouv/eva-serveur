module AvecNomTechnique
  extend ActiveSupport::Concern

  included do
    validates :nom_technique, presence: true, uniqueness: true
  end

  def nom_technique_sans_variant
    nom_technique.split("__").first
  end
end
