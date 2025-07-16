class TableauComponent < ViewComponent::Base
  def initialize(collection:, actions: true)
    @collection = collection
    @colonnes = []
    @actions = actions
  end

  def colonne(titre:, &block)
    @colonnes << { titre: titre, block: block }
  end

  def before_render
    content if content.present?
  end

  def actions?
    actions
  end

  private

  attr_reader :titre, :collection, :colonnes, :actions
end
