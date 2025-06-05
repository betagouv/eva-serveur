# frozen_string_literal: true

class CodeComponent < ViewComponent::Base
  def initialize(code)
    @code = code
  end

  def classe_couleur_pour_caractere(caractere)
    couleur = caractere.match(/[0-9]/) ? "violet" : "bleu"
    "code--#{couleur}"
  end
end
