# frozen_string_literal: true

class Actualite < ApplicationRecord
  has_one_attached :illustration
  enum categorie: %i[blog assistance evolution]

  validates :titre, :contenu, :categorie, presence: true
  validates :titre, length: { maximum: 60 }

  def display_name
    titre
  end

  def recentes_sauf_moi(nombre)
    Actualite.order(created_at: :desc).where.not(id: id).first(nombre)
  end
end
