# frozen_string_literal: true

class RechercheStructureComponentStories < ViewComponent::Storybook::Stories
  story :sans_compte_courrant_ni_params do
    constructor(recherche_url: '/structures')
  end
end
