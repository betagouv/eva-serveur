json.array! @structures_locales do |structure|
  json.extract! structure, :id, :nom, :code_postal
  json.display_name structure.display_name
end
