class GenerateurCode
  TAILLE_PREFIXE = 3
  TAILLE_SUFFIXE_ALEATOIRE = 5
  PREFIXES_EXCLUS = Set.new(ENV.fetch("PREFIXES_CODE_EXCLUS", "").split)

  def initialize(modele, colonne)
    @modele = modele
    @colonne = colonne
  end

  def genere(suffixe = nil)
    loop do
      prefixe = GenerateurAleatoire.majuscules(TAILLE_PREFIXE)
      next if PREFIXES_EXCLUS.include?(prefixe)

      code = prefixe + (suffixe || GenerateurAleatoire.nombres(TAILLE_SUFFIXE_ALEATOIRE).to_s)
      return code unless @modele.with_deleted.exists?(@colonne => code)
    end
  end
end
