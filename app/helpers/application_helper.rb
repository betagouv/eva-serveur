# frozen_string_literal: true

module ApplicationHelper
  def en_pourcentage(nombre)
    number_to_percentage(nombre, precision: 0)
  end

  def rapport_colonne_class
    'col-4 px-5 mb-4'
  end
end
