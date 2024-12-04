# frozen_string_literal: true

class PastilleComponentStories < ViewComponent::Storybook::Stories
  story :illettrisme_potentiel do
    constructor(tooltip_content: 'Illettrisme potentiel', couleur: 'alerte')
  end

  story :illettrisme_potentiel_legende do
    constructor(etiquette: "Évaluations contenant un diagnostic d'illettrisme potentiel",
                couleur: 'alerte')
  end
end
