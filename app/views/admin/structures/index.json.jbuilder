# frozen_string_literal: true

json.array! @structures do |structure|
  json.merge! structure.attributes
  json.display_name structure.display_name
end
