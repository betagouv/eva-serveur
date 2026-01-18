json.array! @comptes do |compte|
  json.extract! compte, :id, :email, :nom, :prenom
  json.display_name compte.display_name
end
