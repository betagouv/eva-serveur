# frozen_string_literal: true

class TexteIntroComponent < ViewComponent::Base
  def initialize(titre: nil, texte: nil, classes: "")
    @titre = titre
    @texte = texte
    @classes = classes
  end
end
