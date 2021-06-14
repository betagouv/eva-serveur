# frozen_string_literal: true

json.array! @comptes do |compte|
  json.merge! compte.attributes
  json.display_name compte.display_name
end
