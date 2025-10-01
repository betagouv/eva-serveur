json.array! @comptes do |compte|
  json.merge! compte.attributes
  json.display_name compte.display_name
end
