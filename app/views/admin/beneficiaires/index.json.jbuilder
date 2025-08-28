# frozen_string_literal: true

json.array! @beneficiaires do |beneficiaire|
  json.merge! beneficiaire.attributes
  json.display_name beneficiaire.display_name
end
