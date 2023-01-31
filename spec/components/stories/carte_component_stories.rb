# frozen_string_literal: true

class CarteComponentStories < ViewComponent::Storybook::Stories
  story :default do
    constructor('') do
      'Ceci est une carte.'
    end
  end
end
