json.array! @questions do |question|
  json.extract! question, :id, :libelle, :nom_technique
  json.display_name question.display_name
end
