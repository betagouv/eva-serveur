# frozen_string_literal: true

class Tag < ViewComponent::Base
  def initialize(contenu, supprimable: false, classes: nil, url: nil)
    @contenu = contenu
    @supprimable = supprimable
    @classes = classes
    @url = url
  end
end
