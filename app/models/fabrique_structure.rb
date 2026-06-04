class FabriqueStructure
  def self.cree_depuis_siret(siret, attributs_structure = {}, validation_inscription: false)
    structure = RechercheStructureParSiret.new(siret).call
    return nil if structure.blank?

    structure.assign_attributes(attributs_structure)
    structure.validation_inscription = validation_inscription

    structure.save
    structure
  end
end
