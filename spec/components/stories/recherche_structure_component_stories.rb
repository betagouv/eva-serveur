# frozen_string_literal: true

class RechercheStructureComponentStories < ViewComponent::Storybook::Stories
  story :sans_compte_courrant_ni_params do
    constructor(recherche_url: '/structures')
  end

  story :sans_compte_courrant do
    constructor(recherche_url: '/structures',
                ville_ou_code_postal: 'Strasbourg (67200)',
                code_postal: '67200')
  end

  story :avec_compte_courrant do
    constructor(recherche_url: '/structures',
                current_compte: 'compte_id',
                ville_ou_code_postal: 'Strasbourg (67200)',
                code_postal: '67200')
  end
end
