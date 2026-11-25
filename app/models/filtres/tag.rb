module Filtres
  Tag = Data.define(:libelle, :nom, :valeur) do
    # nom est le nom du champ du formulaire : q[statut_in][], q[nom_eq] ou scope
    def retire_de(parametres)
      reste = parametres.deep_dup.except("page")
      parent = chemin.empty? ? reste : reste.dig(*chemin)
      retire_valeur(parent) if parent.is_a?(Hash)
      reste
    end

    private

    def chemin
      cles[0...-1]
    end

    def cle
      cles.last
    end

    def cles
      nom.to_s.scan(/[^\[\]]+/)
    end

    def retire_valeur(parent)
      restantes = Array(parent[cle]) - [ valeur.to_s ]
      if nom.to_s.end_with?("[]") && restantes.any?
        parent[cle] = restantes
      else
        parent.delete(cle)
      end
    end
  end
end
