# frozen_string_literal: true

class GenerateurAleatoire
  class << self
    def majuscules(longueur)
      [*('A'..'Z')].sample(longueur).join
    end
  end
end
