# frozen_string_literal: true

class ReferentielAnlciComponentStories < ViewComponent::Storybook::Stories
  story :default do
    type = select(%w[version_eva officiel], 'version_eva')
    constructor(type)
  end
end
