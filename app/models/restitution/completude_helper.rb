# frozen_string_literal: true

module Restitution
  class CompletudeHelper
    def initialize(evaluation, restitutions)
      @evaluation = evaluation
      @restitutions = restitutions
    end

    def complete?
      ids_situations_ct = ids_situations(@evaluation.campagne_id,
                                         Evaluation::SITUATION_COMPETENCES_TRANSVERSALES)
      ids_situations_cdb = ids_situations(@evaluation.campagne_id,
                                          Evaluation::SITUATION_COMPETENCES_BASE)

      ct_incompletes = !completude?(ids_situations_ct)
      cdb_incompletes = !completude?(ids_situations_cdb)

      return :incomplete if ct_incompletes && cdb_incompletes
      return :competences_transversales_incompletes if ct_incompletes
      return :competences_de_base_incompletes if cdb_incompletes

      :complete
    end

    def ids_situations(id_campagne, noms_techniques)
      SituationConfiguration.joins(:situation)
                            .where(campagne_id: id_campagne)
                            .where(situations: { nom_technique: noms_techniques })
                            .pluck(:situation_id)
    end

    private

    def completude?(situation_ids)
      situation_ids.all? do |situation_id|
        @restitutions.select do |restitution|
          restitution.situation.id == situation_id
        end.any?(&:termine?)
      end
    end
  end
end
