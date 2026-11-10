module EvaluationsEva
  class StatutSuivi
    ORDRE_DE_TRI = {
      "suite_engagee" => 1,
      "reporte" => 2,
      "pas_de_suite" => 3,
      "a_renseigner" => 4,
      "non_concerne" => 5
    }.freeze
    STATUTS = ORDRE_DE_TRI.keys.freeze
    STATUTS_FILTRE = %w[a_renseigner reporte suite_engagee pas_de_suite].freeze

    def self.par_evaluation(ids)
      EvaluationEva.where(id: ids).pluck(:id, sql_statut_suivi).to_h
    end

    def self.filtre_par_statuts(relation, statuts)
      relation.where("#{sql_statut_suivi} IN (?)", statuts & STATUTS_FILTRE)
    end

    # Calcule le statut de suivi de chaque évaluation, en SQL pour pouvoir trier et filtrer
    def self.sql_statut_suivi
      Arel.sql(<<~SQL.squish)
        CASE
          WHEN NOT (#{sql_evaluation_suivie}) THEN 'non_concerne'
          WHEN #{sql_mise_en_action_reportee} THEN 'reporte'
          WHEN #{sql_reponse_mise_en_action} IS NULL THEN 'a_renseigner'
          WHEN #{sql_reponse_mise_en_action} THEN 'suite_engagee'
          ELSE 'pas_de_suite'
        END
      SQL
    end

    def self.sql_ordre_de_tri
      sql_ordre_de_tri_pour(sql_statut_suivi)
    end

    def self.sql_ordre_de_tri_pour(sql_statut)
      cas = ORDRE_DE_TRI.map { |statut, ordre| "WHEN '#{statut}' THEN #{ordre}" }.join(" ")
      Arel.sql("CASE #{sql_statut} #{cas} END")
    end

    # La structure dans laquelle l'évaluation a été passée
    def self.sql_structure_de_levaluation
      <<~SQL.squish
        (SELECT comptes.structure_id FROM campagnes
         JOIN comptes ON comptes.id = campagnes.compte_id
         WHERE campagnes.id = evaluations.campagne_id)
      SQL
    end

    # La déclaration qui vaut pour la personne dans la structure de l'évaluation (EVA-1186) :
    # une réponse donnée sur une autre évaluation de la même personne y vaut aussi
    def self.sql_mise_en_action_en_cours
      <<~SQL.squish
        mises_en_action.deleted_at IS NULL
        AND mises_en_action.remplacee_le IS NULL
        AND mises_en_action.beneficiaire_id = evaluations.beneficiaire_id
        AND mises_en_action.structure_id = #{sql_structure_de_levaluation}
      SQL
    end

    # La réponse Oui (true), Non (false), ou NULL sans réponse
    def self.sql_reponse_mise_en_action
      <<~SQL.squish
        (SELECT mises_en_action.effectuee FROM mises_en_action
         WHERE #{sql_mise_en_action_en_cours} LIMIT 1)
      SQL
    end

    # Vrai si la mise en action de l'évaluation est reportée : le pro a répondu "Pas encore"
    # et sa date de revue n'est pas atteinte
    def self.sql_mise_en_action_reportee
      <<~SQL.squish
        EXISTS (SELECT 1 FROM mises_en_action
                WHERE #{sql_mise_en_action_en_cours}
                AND mises_en_action.effectuee IS NULL
                AND mises_en_action.repondue_le IS NOT NULL
                AND mises_en_action.date_revue > CURRENT_DATE)
      SQL
    end

    # L'évaluation entre dans le suivi : illettrisme potentiel, compétences de base complètes,
    # passée depuis DATE_STATUT_SUIVI, bénéficiaire non anonymisé
    def self.sql_evaluation_suivie
      debut = date_debut_suivi
      return "FALSE" if debut.nil?

      <<~SQL.squish
        evaluations.synthese_competences_de_base = 'illettrisme_potentiel'
        AND evaluations.completude IN ('complete', 'competences_transversales_incompletes')
        AND evaluations.debutee_le >= #{ActiveRecord::Base.connection.quote(debut)}
        AND EXISTS (SELECT 1 FROM beneficiaires
                    WHERE beneficiaires.id = evaluations.beneficiaire_id
                    AND beneficiaires.anonymise_le IS NULL)
      SQL
    end

    def self.date_debut_suivi
      date = ENV["DATE_STATUT_SUIVI"]
      return if date.blank?

      Time.zone.parse(date)
    end
  end
end
