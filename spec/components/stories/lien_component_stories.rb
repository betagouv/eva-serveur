# frozen_string_literal: true

class LienComponentStories < ViewComponent::Storybook::Stories
  story :default do
    body = text('Lien')
    url = text('https://eva.beta.gouv.fr/cgu')
    constructor(body, url)
  end

  story :externe do
    body = text('Lien')
    url = text('https://eva.beta.gouv.fr/cgu')
    constructor(body, url, externe: true)
  end
end
