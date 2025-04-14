# frozen_string_literal: true

class AnnonceGenerale < ApplicationRecord
  validates :texte, presence: true

  def display_name
    "Annonce"
  end
end
