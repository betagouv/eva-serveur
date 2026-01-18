json.array! @campagnes do |campagne|
  json.extract! campagne, :id, :libelle, :code
  json.display_name campagne.display_name
end
