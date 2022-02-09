# frozen_string_literal: true

module StructureHelper
  def traduction_type_structure(type_structure)
    I18n.t(
      "activerecord.attributes.structure.type_structure.#{type_structure}"
    )
  end

  def collection_types_structures
    StructureLocale::TYPES_STRUCTURES.map do |type_structure|
      [traduction_type_structure(type_structure), type_structure]
    end
  end
end
