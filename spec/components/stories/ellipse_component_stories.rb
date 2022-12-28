# frozen_string_literal: true

class EllipseComponentStories < ViewComponent::Storybook::Stories
  story :ellipse do
    statut = select(%i[succes desactive active], :succes)
    constructor(statut)
  end
end
