json.array! @beneficiaires do |beneficiaire|
  json.extract! beneficiaire, :id, :nom, :code_beneficiaire
  json.display_name beneficiaire.display_name
end
