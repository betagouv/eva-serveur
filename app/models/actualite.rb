# frozen_string_literal: true

class Actualite < ApplicationRecord
  has_one_attached :illustration
  enum :categorie, { blog: 0, assistance: 1, evolution: 2 }

  validates :titre, :contenu, :categorie, presence: true
  validates :titre, length: { maximum: 100 }

  def display_name
    titre
  end

  def recentes_sauf_moi(nombre)
    Actualite.order(created_at: :desc).where.not(id: id).first(nombre)
  end
end
