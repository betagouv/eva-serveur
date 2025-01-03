# frozen_string_literal: true

module ImportExport
  module Positionnement
    class ExportDonnees
      ENTETES_LITTERATIE = [
        { titre: 'Code Question', taille: 20 },
        { titre: 'Intitulé', taille: 80 },
        { titre: 'Réponse', taille: 45 },
        { titre: 'Score', taille: 10 },
        { titre: 'Score max', taille: 10 },
        { titre: 'Métacompétence', taille: 20 }
      ].freeze
      ENTETES_NUMERATIE = [
        { titre: 'Code cléa', taille: 10 },
        { titre: 'Item', taille: 20 },
        { titre: 'Méta compétence', taille: 20 },
        { titre: 'Interaction', taille: 20 },
        { titre: 'Intitulé de la question', taille: 80 },
        { titre: 'Réponses possibles', taille: 20 },
        { titre: 'Réponses attendue', taille: 20 },
        { titre: 'Réponse du bénéficiaire', taille: 20 },
        { titre: 'Score attribué', taille: 10 },
        { titre: 'Score possible de la question', taille: 10 }
      ].freeze

      ENTETES_SYNTHESE = [
        { titre: 'Points', taille: 20 },
        { titre: 'Points maximum', taille: 10 },
        { titre: 'Score', taille: 10 }
      ].freeze

      def initialize(partie)
        @partie = partie
      end

      def entetes
        @partie.situation.litteratie? ? ENTETES_LITTERATIE : ENTETES_NUMERATIE
      end
    end
  end
end
