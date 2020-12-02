# frozen_string_literal: true

class SourceAide < ApplicationRecord
  enum categorie: %i[prise_en_main]
  enum type_document: %i[video pdf repertoire]

  validates :titre, :description, :url, :categorie, :type_document, presence: true

  def display_name
    titre
  end
end
