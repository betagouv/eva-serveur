# frozen_string_literal: true

module Restitution
  class Maintenance < AvecEntrainement
    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementMaintenanceDecorator.new e }
      super(campagne, evenements)
    end

    def metrique(nom)
      Metriques::MAINTENANCE[nom]
        .new(evenements_situation)
        .calcule
    end
  end
end
