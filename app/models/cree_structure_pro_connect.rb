class CreeStructureProConnect
  def initialize(compte, structure_params)
    @compte = compte
    @structure_params = structure_params
  end

  def call
    # Récupère ou crée la structure temporaire
    structure = recupere_structure_temporaire
    return { success: false, structure: structure } if structure.nil?

    # Applique les paramètres du formulaire
    structure.assign_attributes(@structure_params)

    # Sauvegarde la structure
    if structure.save
      assigne_structure_au_compte(structure)
      { success: true, structure: structure, compte: @compte }
    else
      { success: false, structure: structure }
    end
  end

  private

  def recupere_structure_temporaire
    # Si le compte a déjà une structure, on la retourne
    return @compte.structure if @compte.structure.present?

    # Sinon, on crée une structure temporaire via le service
    compte_avec_structure = RechercheStructureParSiret.new(@compte, @compte.siret_pro_connect).call
    compte_avec_structure.structure
  end

  def assigne_structure_au_compte(structure)
    @compte.structure = structure
    @compte.assigne_role_admin_si_pas_d_admin
    @compte.etape_inscription = :complet
    @compte.save
  end
end
