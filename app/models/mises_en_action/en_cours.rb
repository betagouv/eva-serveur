module MisesEnAction
  # La déclaration qui vaut aujourd'hui pour une personne dans une structure : une seule à la
  # fois, quelle que soit l'évaluation depuis laquelle la réponse a été donnée (EVA-1186).
  #
  # La règle est écrite ici une fois pour les deux usages : la recherche d'un enregistrement
  # (#pour) et la condition SQL corrélée aux évaluations (#sql_correlee_a_levaluation), dont
  # les statuts de suivi ont besoin pour trier et filtrer.
  class EnCours
    def self.pour(beneficiaire_id, structure_id)
      return if beneficiaire_id.blank? || structure_id.blank?

      MiseEnAction.en_cours
                  .find_by(beneficiaire_id: beneficiaire_id, structure_id: structure_id)
    end

    # Se greffe sur une requête qui porte déjà sur evaluations et mises_en_action
    def self.sql_correlee_a_levaluation
      <<~SQL.squish
        mises_en_action.deleted_at IS NULL
        AND mises_en_action.remplacee_le IS NULL
        AND mises_en_action.beneficiaire_id = evaluations.beneficiaire_id
        AND mises_en_action.structure_id = #{sql_structure_de_levaluation}
      SQL
    end

    # La structure dans laquelle l'évaluation a été passée
    def self.sql_structure_de_levaluation
      <<~SQL.squish
        (SELECT comptes.structure_id FROM campagnes
         JOIN comptes ON comptes.id = campagnes.compte_id
         WHERE campagnes.id = evaluations.campagne_id)
      SQL
    end
    private_class_method :sql_structure_de_levaluation
  end
end
