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

    def self.avec_statut(relation)
      relation.left_joins(:mise_en_action, :beneficiaire)
              .select("evaluations.*",
                      "#{expression_statut} AS statut_suivi",
                      "#{expression_rang} AS statut_suivi_rang")
    end

    def self.expression_statut
      <<~SQL.squish
        CASE
          WHEN NOT (#{condition_concernee}) THEN 'non_concerne'
          WHEN mises_en_action.id IS NULL THEN 'a_renseigner'
          WHEN mises_en_action.effectuee THEN 'suite_engagee'
          ELSE 'pas_de_suite'
        END
      SQL
    end

    def self.expression_rang
      cas = RANGS.map { |statut, rang| "WHEN '#{statut}' THEN #{rang}" }.join(" ")
      "CASE #{expression_statut} #{cas} END"
    end

    def self.condition_concernee
      debut = date_debut
      return "FALSE" if debut.nil?

      <<~SQL.squish
        evaluations.synthese_competences_de_base = 'illettrisme_potentiel'
        AND evaluations.completude IN ('complete', 'competences_transversales_incompletes')
        AND beneficiaires.anonymise_le IS NULL
        AND evaluations.debutee_le >= #{ActiveRecord::Base.connection.quote(debut)}
      SQL
    end

    def self.date_debut
      date = ENV["DATE_STATUT_SUIVI"]
      return if date.blank?

      Time.zone.parse(date).beginning_of_day
    end
  end
end
