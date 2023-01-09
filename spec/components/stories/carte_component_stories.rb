# frozen_string_literal: true

class CarteComponentStories < ViewComponent::Storybook::Stories
  story :carte_avec_nom do
    nom = 'Tom Preston'
    constructor(nom, '')
  end
end
