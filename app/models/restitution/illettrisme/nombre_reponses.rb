module Restitution
  module Illettrisme
    class NombreReponses
      def calcule(evenements, metacompetence)
        evenements.select do |evenement|
          evenement.metacompetence == metacompetence &&
            evenement.nom == MetriquesHelper::EVENEMENT[:REPONSE]
        end.count
      end
    end
  end
end
