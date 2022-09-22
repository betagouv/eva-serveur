# frozen_string_literal: true

class ParcoursTypeCategorie < ApplicationRecord
  def display_name
    nom
  end
end
