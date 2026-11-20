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

  def url_effacer
    parametres = @parametres_conserves.dup
    if recherche? && recherche.valeur.present?
      parametres[:q] = { recherche.champ => recherche.valeur }
    end
    parametres.empty? ? @url : "#{@url}?#{parametres.to_query}"
  end
end
