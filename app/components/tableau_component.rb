class TableauComponent < ViewComponent::Base
  def initialize(collection:)
    @collection = collection
    @colonnes = []
  end

  def colonne(titre: nil, td_class: nil, &block)
    @colonnes << { titre: titre, td_class: td_class, block: block }
  end

  def before_render
    content if content.present?
  end

  private

  attr_reader :collection, :colonnes
end
