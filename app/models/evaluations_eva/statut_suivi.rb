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

    # La réponse Oui (true), Non (false), ou NULL sans réponse
    def self.sql_reponse_mise_en_action
      <<~SQL.squish
        (SELECT mises_en_action.effectuee FROM mises_en_action
         WHERE mises_en_action.evaluation_id = evaluations.id
         AND mises_en_action.deleted_at IS NULL)
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
