json.array! @campagnes do |campagne|
  json.merge! campagne.attributes
  json.display_name campagne.display_name
end
