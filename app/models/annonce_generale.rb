class AnnonceGenerale < ApplicationRecord
  validates :texte, presence: true

  def display_name
    "Annonce"
  end
end
