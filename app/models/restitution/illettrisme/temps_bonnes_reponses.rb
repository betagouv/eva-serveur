module Restitution
  module Illettrisme
    class TempsBonnesReponses
      def calcule(evenements, metacompetence)
        Restitution::MetriquesHelper.temps_action(evenements, :bonne_reponse?) do |evenement|
          evenement.metacompetence == metacompetence
        end
      end
    end
  end
end
