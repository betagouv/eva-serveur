# frozen_string_literal: true

FactoryBot.define do
  factory :evenement do
    nom { 'ouvertureContenant' }
    donnees { {} }
    situation { 'inventaire' }
    session_id { '07319b2485be9ac4850664cd47cede38' }
    date { DateTime.now }

    factory :evenement_demarrage do
      nom { 'demarrage' }
    end

    factory :evenement_rejoue_consigne do
      nom { 'rejoueConsigne' }
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

    factory :evenement_stop do
      nom { 'stop' }
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
  end
end
