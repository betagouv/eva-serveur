module StructureHelper
  def opcos_associes(structure)
    if structure.persisted?
      structure.opcos
    else
      # Pour les structures non persistées, on accède aux OPCOs via structure_opcos
      structure.structure_opcos.map(&:opco).compact
    end
  end

  def opco_ids_associes(structure)
    if structure.persisted?
      structure.opco_ids
    else
      # Pour les structures non persistées, on récupère les IDs depuis structure_opcos
      structure.structure_opcos.map { |so| so.opco&.id }.compact
    end
  end

  def opco_id_associe(structure)
    opco_ids = opco_ids_associes(structure)
    opco_ids.first
  end

  def adresse_ou_code_postal(structure)
    return structure.adresse if structure.adresse.present?
    return structure.code_postal if structure.code_postal.present?

    nil
  end
  def traduction_type_structure(type_structure)
    I18n.t(
      "activerecord.attributes.structure.type_structure.#{type_structure}"
    )
  end

  def collection_types_structures
    StructureLocale::TYPES_STRUCTURES.map do |type_structure|
      [ traduction_type_structure(type_structure), type_structure ]
    end
  end

  def collection_opcos
    Opco.order(:nom).map { |opco| [ opco.nom, opco.id ] }
  end

  def cree_structure_demo
    StructureLocale.transaction do
      StructureLocale.where(nom: Eva::STRUCTURE_DEMO).first_or_create do |s|
        s.type_structure = :autre
        s.code_postal = "69003"
        s.siret = "12345678901234"
      end
    end
  end

  def vide_compte(compte)
    Campagne.with_deleted.where(compte: compte).find_each do |campagne|
      logger.info "destruction de la campagne #{campagne.libelle}"
      Evaluation.with_deleted.where(campagne: campagne).find_each do |evaluation|
        b = evaluation.beneficiaire
        evaluation.really_destroy!
        b.really_destroy! unless Evaluation.with_deleted.exists?(beneficiaire: b)
      end
      campagne.really_destroy!
    end
  end

  def badge_class(autorisation_creation_campagne)
    autorisation_creation_campagne ? "fr-badge--green-emeraude" : "fr-badge--orange-terre-battue"
  end

  def traduction_autorisation_creation_campagne(autorisation_creation_campagne)
    I18n.t("activerecord.attributes.structure.autorisation_creation_campagne_#{autorisation_creation_campagne}") # rubocop:disable Layout/LineLength
  end

  def format_statut_siret(statut_siret)
    return I18n.t("activerecord.attributes.structure.statut_siret_false") if statut_siret.nil?

    I18n.t("activerecord.attributes.structure.statut_siret_#{statut_siret}")
  end
end
