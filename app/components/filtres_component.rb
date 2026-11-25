class FiltresComponent < ViewComponent::Base
  renders_one :recherche, Filtres::BarreRechercheComponent
  renders_many :filtres, Filtres::MenuComponent

  def initialize(url:, id:, parametres_conserves: {})
    @url = url
    @id = id
    @parametres_conserves = parametres_conserves.compact_blank
  end

  def id_menu(index)
    "#{@id}-filtre-#{index}"
  end

  def filtres_actifs?
    filtres.any?(&:actif?)
  end

  def tags
    filtres.flat_map(&:tags)
  end

  def url_sans(tag)
    parametres = tag.retire_de(request.query_parameters)
    parametres.empty? ? @url : "#{@url}?#{parametres.to_query}"
  end
end
