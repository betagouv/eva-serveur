# frozen_string_literal: true

module ApplicationHelper
  def en_pourcentage(nombre)
    number_to_percentage(nombre, precision: 0)
  end
end
