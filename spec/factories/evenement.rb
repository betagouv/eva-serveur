FactoryBot.define do
  factory :evenement do
    nom { 'nom_evenement' }
    donnees { {} }
    partie
    sequence(:position)
    date { DateTime.now }
    session_id { partie.session_id }

    factory :evenement_demarrage_entrainement do
      nom { 'demarrageEntrainement' }
    end

    factory :evenement_demarrage do
      nom { 'demarrage' }
    end

    factory :evenement_rejoue_consigne do
      nom { 'rejoueConsigne' }
    end

    factory :evenement_fin_situation do
      nom { 'finSituation' }
    end

    factory :evenement_saisie_inventaire do
      nom { 'saisieInventaire' }

      trait :ok do
        donnees do
          { reussite: true, reponses: {} }
        end
      end

      trait :echec do
        donnees do
          { reussite: false, reponses: {} }
        end
      end
    end

    factory :evenement_ouverture_contenant do
      nom { 'ouvertureContenant' }
      donnees { { contenant: 1 } }
    end

    factory :evenement_abandon do
      nom { 'abandon' }
    end

    factory :evenement_piece_bien_placee do
      nom { 'pieceBienPlacee' }
    end

    factory :evenement_piece_mal_placee do
      nom { 'pieceMalPlacee' }
    end

    factory :evenement_piece_non_triee do
      nom { 'pieceRatee' }
    end

    factory :evenement_reponse do
      nom { 'reponse' }
    end

    factory :evenement_qualification_danger do
      nom { 'qualificationDanger' }

      trait :bon do
        donnees { { reponse: 'bonne' } }
      end

      trait :mauvais do
        donnees { { reponse: 'mauvaise' } }
      end
    end

    factory :evenement_identification_danger do
      nom { 'identificationDanger' }
    end

    factory :activation_aide do
      nom { 'activationAide' }
    end

    factory :evenement_ouverture_zone do
      nom { 'ouvertureZone' }
    end

    factory :evenement_apparition_mot do
      nom { 'apparitionMot' }
    end

    factory :evenement_identification_mot do
      nom { 'identificationMot' }

      trait :pas_français_bien_identifie do
        donnees { { type: 'non-mot', reponse: 'pasfrancais' } }
      end

      trait :pas_français_mal_identifie do
        donnees { { type: 'non-mot', reponse: 'francais' } }
      end

      trait :non_reponse do
        donnees { { type: 'non-mot' } }
      end
    end

    factory :evenement_affichage_question_qcm do
      nom { 'affichageQuestionQCM' }
    end
  end
end
