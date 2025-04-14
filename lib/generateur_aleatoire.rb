# frozen_string_literal: true

class GenerateurAleatoire
  class << self
    def majuscules(longueur)
      ("A".."Z").to_a.sample(longueur).join
    end
  end
end
