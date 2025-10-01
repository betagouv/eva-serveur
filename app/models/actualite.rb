class Actualite < ApplicationRecord
  has_one_attached :illustration
  enum :categorie, { blog: 0, assistance: 1, evolution: 2 }

  validates :titre, :contenu, :categorie, presence: true
  validates :titre, length: { maximum: 100 }

  def self.tableau_de_bord(ability)
    accessible_by(ability)
      .order(created_at: :desc)
      .includes(illustration_attachment: :blob)
  end

  def display_name
    titre
  end

  def recentes_sauf_moi(nombre)
    Actualite.order(created_at: :desc).where.not(id: id).first(nombre)
  end
end
