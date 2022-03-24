# frozen_string_literal: true

module Evenements
  module PersisteMetriques
    extend ActiveSupport::Concern
    FIN_SITUATION = 'finSituation'

    included do
      after_commit :persiste_si_fin_partie
    end

    def persiste_si_fin_partie
      PersisteMetriquesPartieJob.perform_later(partie) if nom == FIN_SITUATION
    end
  end
end
