# frozen_string_literal: true

module StructureHelper
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

  def cree_structure_demo
    StructureLocale.transaction do
      StructureLocale.where(nom: Eva::STRUCTURE_DEMO).first_or_create do |s|
        s.type_structure = :autre
        s.code_postal = "69003"
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
end
