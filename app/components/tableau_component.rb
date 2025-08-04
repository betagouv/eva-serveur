class TableauComponent < ViewComponent::Base
  def initialize(collection:, selectionnable: false)
    @collection = collection
    @colonnes = []
    @selectionnable = selectionnable
  end

  def colonne(titre: nil, td_class: "", &block)
    @colonnes << { titre: titre, td_class: td_class, block: block }
  end

  def before_render
    content if content.present?
  end

  private

  attr_reader :collection, :colonnes
end
