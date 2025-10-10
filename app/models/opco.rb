class Opco < ApplicationRecord
  validates :nom, presence: true

  def display_name
    nom
  end
end
