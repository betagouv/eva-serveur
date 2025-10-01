class GenerateurAleatoire
  class << self
    def majuscules(longueur)
      ("A".."Z").to_a.sample(longueur).join
    end

    def nombres(longueur)
      chiffres = [ rand(1..9) ] # premier chiffre non nul
      (longueur - 1).times { chiffres << rand(0..9) }
      chiffres.join.to_i
    end
  end
end
