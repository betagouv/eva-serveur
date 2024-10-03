# frozen_string_literal: true

class BoutonComponentStories < ViewComponent::Storybook::Stories
  story :default do
    body = text('Bouton')
    url = text('https://preprod.eva.beta.gouv.fr/pro')
    constructor(body, url)
  end

  story :primary do
    body = text('Bouton')
    url = text('https://preprod.eva.beta.gouv.fr/pro')
    constructor(body, url, type: :primary)
  end

  story :secondary do
    body = text('Bouton')
    url = text('https://preprod.eva.beta.gouv.fr/pro')
    constructor(body, url, type: :secondary)
  end

  story :desactive do
    body = text('Bouton')
    url = text('https://preprod.eva.beta.gouv.fr/pro')
    constructor(body, url, type: :desactive)
  end
end
