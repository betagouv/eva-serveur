class TableauComponent < ViewComponent::Base
  def initialize(collection:, selectionnable: false, **params)
    @collection = collection
    @colonnes = []
    @selectionnable = selectionnable
    @params = params
  end

  def colonne(titre: nil, td_class: "", &block)
    @colonnes << { titre: titre, td_class: td_class, block: block }
  end

  def before_render
    content if content.present?
  end

  def data_id(item, index)
    if item.respond_to?(:id)
      item.id
    else
      "id_inconnu"
    end
  end

  private

  attr_reader :collection, :colonnes
end
