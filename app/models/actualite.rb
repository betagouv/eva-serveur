# frozen_string_literal: true

class Actualite < ApplicationRecord
  enum categorie: %i[blog assistance evolution]

  validates :titre, :contenu, :categorie, presence: true
end
