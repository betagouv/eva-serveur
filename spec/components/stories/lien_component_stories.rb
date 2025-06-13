# frozen_string_literal: true

class LienComponentStories < ViewComponent::Storybook::Stories
  story :default do
    body = text('Lien')
    url = text('https://eva.anlci.gouv.fr/condition-generales-dutilisation/')
    constructor(body, url)
  end

  story :accessible do
    body = text('Lien')
    url = text('https://eva.anlci.gouv.fr/condition-generales-dutilisation/')
    constructor(body, url, aria: { label: "c'est mon lien" })
  end

  story :externe do
    body = text('Lien')
    url = text('https://eva.anlci.gouv.fr/condition-generales-dutilisation/')
    constructor(body, url, externe: true)
  end

  story :externe_accessible do
    body = text('Lien')
    url = text('https://eva.anlci.gouv.fr/condition-generales-dutilisation/')
    constructor(body, url, aria: { label: "c'est mon lien" }, externe: true)
  end
end
