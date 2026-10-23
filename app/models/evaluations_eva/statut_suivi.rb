module EvaluationsEva
  class StatutSuivi
    RANGS = {
      "suite_engagee" => 1,
      "reporte" => 2,
      "pas_de_suite" => 3,
      "a_renseigner" => 4,
      "non_concerne" => 5
    }.freeze
    STATUTS = RANGS.keys.freeze

    def self.par_evaluation(ids)
      EvaluationEva.where(id: ids).pluck(:id, expression_statut).to_h
    end

    def self.expression_statut
      Arel.sql(<<~SQL.squish)
        CASE
          WHEN NOT (#{condition_concernee}) THEN 'non_concerne'
          WHEN #{reponse_mise_en_action} IS NULL THEN 'a_renseigner'
          WHEN #{reponse_mise_en_action} THEN 'suite_engagee'
          ELSE 'pas_de_suite'
        END
      SQL
    end

    def self.expression_rang
      cas = RANGS.map { |statut, rang| "WHEN '#{statut}' THEN #{rang}" }.join(" ")
      Arel.sql("CASE #{expression_statut} #{cas} END")
    end

    def self.reponse_mise_en_action
      <<~SQL.squish
        (SELECT mises_en_action.effectuee FROM mises_en_action
         WHERE mises_en_action.evaluation_id = evaluations.id
         AND mises_en_action.deleted_at IS NULL)
      SQL
    end

    def self.condition_concernee
      debut = date_debut
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

    def self.date_debut
      date = ENV["DATE_STATUT_SUIVI"]
      return if date.blank?

      Time.zone.parse(date)
    end
  end
end
