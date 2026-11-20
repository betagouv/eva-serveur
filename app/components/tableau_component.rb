class TableauComponent < ViewComponent::Base
  SENS_TRI = { "asc" => "ascending", "desc" => "descending" }.freeze

  renders_one :entete
  renders_one :pied

  # ordre : tri courant au format ActiveAdmin <colonne>_<asc|desc>
  def initialize(collection:, id: "table-0", selectionnable: false, champ_selection: "row-select",
                 ids_selectionnes: [], ordre: nil, **params)
    @collection = collection
    @id = id
    @colonnes = []
    @selectionnable = selectionnable
    @champ_selection = champ_selection
    @ids_selectionnes = ids_selectionnes.map(&:to_s)
    @ordre = ordre.to_s
    @params = params
  end

  def colonne(titre: nil, td_class: "", multiline: false, tri: nil, &block)
    @colonnes << { titre: titre, td_class: td_class, multiline: multiline, tri: tri,
                   block: block }
  end

  def before_render
    content if content.present?
  end

  def data_id(item, _index = nil)
    if item.respond_to?(:id)
      item.id
    else
      "id_inconnu"
    end
  end

  def selectionne?(item)
    @ids_selectionnes.include?(data_id(item).to_s)
  end

  def sens_tri(colonne)
    return if colonne[:tri].blank?

    SENS_TRI[@ordre.delete_prefix("#{colonne[:tri]}_")] if @ordre.start_with?("#{colonne[:tri]}_")
  end

  def classe_bouton_tri(colonne)
    case sens_tri(colonne)
    when "ascending" then "fr-btn--sort-asc"
    when "descending" then "fr-btn--sort-desc"
    else "fr-btn--sort"
    end
  end

  def url_tri(colonne)
    sens = sens_tri(colonne) == "descending" ? "asc" : "desc"
    parametres = request.query_parameters.except("page", "order")
    "#{request.path}?#{parametres.merge('order' => "#{colonne[:tri]}_#{sens}").to_query}"
  end

  private

  attr_reader :collection, :colonnes
end
