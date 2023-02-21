# frozen_string_literal: true

class TagStories < ViewComponent::Storybook::Stories
  story :default do
    contenu = 'tag'
    constructor(contenu)
  end

  story :supprimable do
    contenu = 'tag'
    constructor(contenu, supprimable: true)
  end

  story :avec_image do
    contenu = 'tag'
    constructor(contenu, image_path: 'demande_aide')
  end
end
