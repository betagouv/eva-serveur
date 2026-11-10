# Une mise en action vaut désormais pour une personne dans une structure (EVA-1186).
# Les déclarations existantes sont rattachées au bénéficiaire et à la structure de leur
# évaluation d'origine ; quand une personne en a plusieurs dans une structure, la plus
# récente reste en cours et les autres sont marquées « remplacées ».
class MigreLesMisesEnActionVersLeBeneficiaire < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL.squish
      UPDATE mises_en_action
      SET beneficiaire_id = evaluations.beneficiaire_id,
          structure_id = comptes.structure_id
      FROM evaluations
      JOIN campagnes ON campagnes.id = evaluations.campagne_id
      JOIN comptes ON comptes.id = campagnes.compte_id
      WHERE evaluations.id = mises_en_action.evaluation_id
    SQL

    execute <<~SQL.squish
      UPDATE mises_en_action
      SET remplacee_le = COALESCE(mises_en_action.repondue_le, mises_en_action.created_at)
      WHERE mises_en_action.deleted_at IS NULL
        AND mises_en_action.beneficiaire_id IS NOT NULL
        AND mises_en_action.structure_id IS NOT NULL
        AND EXISTS (
          SELECT 1 FROM mises_en_action AS plus_recente
          WHERE plus_recente.deleted_at IS NULL
            AND plus_recente.beneficiaire_id = mises_en_action.beneficiaire_id
            AND plus_recente.structure_id = mises_en_action.structure_id
            AND (COALESCE(plus_recente.repondue_le, plus_recente.created_at),
                 plus_recente.created_at)
                > (COALESCE(mises_en_action.repondue_le, mises_en_action.created_at),
                   mises_en_action.created_at)
        )
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE mises_en_action
      SET beneficiaire_id = NULL, structure_id = NULL, remplacee_le = NULL
    SQL
  end
end
