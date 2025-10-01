module Restitution
  module Illettrisme
    class NombreBonnesReponses
      def calcule(evenements, metacompetence)
        evenements.select do |evenement|
          evenement.metacompetence == metacompetence &&
            evenement.bonne_reponse?
        end.count
      end
    end
  end
end
