# frozen_string_literal: true

class EllipseComponentStories < ViewComponent::Storybook::Stories
  story :succes do
    constructor('succes')
  end

  story :desactive do
    constructor('desactive')
  end

  story :active do
    constructor('active')
  end
end
