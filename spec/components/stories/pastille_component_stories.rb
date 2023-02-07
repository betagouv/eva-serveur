# frozen_string_literal: true

class PastilleComponentStories < ViewComponent::Storybook::Stories
  story :illettrisme_potentiel do
    constructor(tooltip_content: 'Illettrisme potentiel', couleur: 'alerte')
  end
end
