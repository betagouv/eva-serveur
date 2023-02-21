# frozen_string_literal: true

class Tag < ViewComponent::Base
  def initialize(contenu, supprimable: false, classes: nil, image_path: nil, url: nil)
    @contenu = contenu
    @supprimable = supprimable
    @classes = classes
    @image_path = image_path
    @url = url
  end
end
