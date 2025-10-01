class SourceAide < ApplicationRecord
  enum :categorie, { prise_en_main: 0, animer_restituer: 1, presenter_eva: 2 }
  enum :type_document, { video: 0, pdf: 1, repertoire: 2, web_doc: 3 }

  validates :titre, :description, :url, :categorie, :type_document, presence: true

  def display_name
    titre
  end

  def self.sources_par_categorie
    order(:categorie).each_with_object({}) do |source, result|
      result[source.categorie] ||= []
      result[source.categorie] << source
    end
  end
end
