# frozen_string_literal: true

class BoutonComponentStories < ViewComponent::Storybook::Stories
  story :default do
    body = text('Bouton')
    url = text('https://preprod.eva.beta.gouv.fr/pro')
    constructor(body, url, type: nil)
  end

  story :primary do
    body = text('Bouton')
    url = text('https://preprod.eva.beta.gouv.fr/pro')
    constructor(body, url, type: :primary)
  end

  story :outline do
    body = text('Bouton')
    url = text('https://preprod.eva.beta.gouv.fr/pro')
    constructor(body, url, type: :outline)
  end
end
