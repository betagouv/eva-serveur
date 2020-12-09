# frozen_string_literal: true

class SourceAide < ApplicationRecord
  enum categorie: %i[prise_en_main animer_restituer presenter_eva]
  enum type_document: %i[video pdf repertoire web_doc]

  validates :titre, :description, :url, :categorie, :type_document, presence: true

  def display_name
    titre
  end

  def self.sources_par_categorie
    all.each_with_object({}) do |source, result|
      result[source.categorie] ||= []
      result[source.categorie] << source
    end
  end
end
