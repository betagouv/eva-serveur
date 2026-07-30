class CampagneCreateur
  def initialize(structure, compte)
    @structure = structure
    @compte = compte
  end

  def cree_campagne_opco!
    return unless doit_creer_campagne?

    parcours_types = @structure.opco.parcours_types
    return if parcours_types.empty?

    parcours_types.each_with_index do |parcours_type, index|
      cree_campagne(parcours_type, libelle: libelle_campagne(index, parcours_types.size))
    end
  end

  private

  def doit_creer_campagne?
    @structure.is_a?(StructureLocale) &&
      @structure.evapro? &&
      @structure.opco.present?
  end

  def libelle_campagne(index, nombre_parcours_types)
    suffix = nombre_parcours_types > 1 ? " #{index + 1}" : ""
    "Diagnostic#{suffix} : #{@structure.nom}"
  end

  def cree_campagne(parcours_type, libelle:)
    campagne = Campagne.new(
      libelle: libelle,
      compte: @compte,
      parcours_type: parcours_type,
      type_programme: parcours_type.type_de_programme
    )

    campagne.save!
    campagne
  end
end
