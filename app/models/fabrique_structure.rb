class FabriqueStructure
  def self.cree_depuis_siret(siret, attributs_structure = {})
    structure = RechercheStructureParSiret.new(siret).call
    return nil if structure.blank?

    structure.assign_attributes(attributs_structure)

    # Si l'usage est "Eva: entreprises", forcer type_structure = "entreprise"
    structure.type_structure = "entreprise" if structure.eva_entreprises?

    structure.save
  end
end
