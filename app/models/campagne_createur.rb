class CampagneCreateur
  NOM_CAMPAGNE_PAR_DEFAUT = "Diagnostic des risques"
  NOM_TECHNIQUE_GENERIQUE = "eva-entreprise"

  def initialize(structure, compte)
    @structure = structure
    @compte = compte
  end

  def cree_campagne_opco!
    return unless doit_creer_campagne?

    parcours_type = trouve_parcours_type
    return unless parcours_type

    # Si l'OPCO est financeur, créer d'abord la campagne générique si elle n'existe pas
    if opco_financeur?
      parcours_type_generique = ParcoursType.find_by(nom_technique: NOM_TECHNIQUE_GENERIQUE)
      if parcours_type_generique && parcours_type != parcours_type_generique
        cree_campagne_generique(parcours_type_generique)
      end
    end

    # Créer la campagne spécifique si elle n'existe pas déjà
    cree_campagne_si_manquante(parcours_type)
  end

  private

  def doit_creer_campagne?
    @structure.is_a?(StructureLocale) &&
      @structure.eva_entreprises? &&
      @structure.opcos.any?
  end

  def trouve_parcours_type
    nom_technique = genere_nom_technique_parcours
    ParcoursType.find_by!(nom_technique: nom_technique)
  end

  def genere_nom_technique_parcours
    return NOM_TECHNIQUE_GENERIQUE unless opco_financeur?

    "#{NOM_TECHNIQUE_GENERIQUE}-#{slugifie_nom_opco}"
  end

  def opco_financeur?
    premier_opco_financeur&.financeur? || false
  end

  def slugifie_nom_opco
    premier_opco_financeur&.nom
              &.unicode_normalize(:nfkd)
              &.encode("ASCII", replace: "")
              &.downcase
              &.gsub(/[^a-z0-9\s-]/, "")
              &.gsub(/\s+/, "") || ""
  end

  def premier_opco_financeur
    @premier_opco_financeur ||= @structure.opcos.find(&:financeur?) || @structure.opcos.first
  end

  def cree_campagne(parcours_type, libelle: nil)
    campagne = Campagne.new(
      libelle: libelle || libelle_campagne_avec_opco,
      compte: compte_pour_structure,
      parcours_type: parcours_type,
      type_programme: parcours_type.type_de_programme
    )

    campagne.save!
    campagne
  end

  def cree_campagne_si_manquante(parcours_type)
    libelle = libelle_campagne_avec_opco
    campagne_existante = trouve_campagne(parcours_type, libelle)
    return campagne_existante if campagne_existante

    cree_campagne(parcours_type)
  end

  def cree_campagne_generique(parcours_type)
    campagne_existante = trouve_campagne(parcours_type, libelle_campagne)
    return campagne_existante if campagne_existante

    cree_campagne(parcours_type, libelle: libelle_campagne)
  end

  def trouve_campagne(parcours_type, libelle)
    return nil if libelle.blank?

    # Normaliser le libellé comme auto_strip_attributes avec squish: true le fait avant sauvegarde
    # Le libellé en base est déjà normalisé par auto_strip_attributes
    libelle_normalise = libelle.to_s.squish.downcase
    return nil if libelle_normalise.blank?

    Campagne.joins(:compte)
            .where("LOWER(campagnes.libelle) = ?", libelle_normalise)
            .where(comptes: { structure_id: @structure.id })
            .where(parcours_type: parcours_type)
            .first
  end

  def libelle_campagne_avec_opco
    return libelle_campagne unless opco_financeur?

    "#{libelle_campagne} (#{premier_opco_financeur.nom})"
  end

  def compte_pour_structure
    return @compte if @compte.structure_id == @structure.id

    @structure.admins.first || @compte
  end

  def libelle_campagne
    "#{NOM_CAMPAGNE_PAR_DEFAUT} : #{@structure.nom}"
  end
end
