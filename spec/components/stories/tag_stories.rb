# frozen_string_literal: true

class TagStories < ViewComponent::Storybook::Stories
  story :default do
    contenu = 'tag'
    constructor(contenu, classes: 'tag-categorie evolution')
  end

  story :supprimable do
    contenu = 'tag'
    constructor(contenu, supprimable: true, classes: 'tag-categorie evolution')
  end
end
