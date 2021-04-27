# frozen_string_literal: true

FactoryBot.define do
  factory :situation do
    libelle { 'Situation demo' }
    nom_technique { 'situation_demo' }

    factory :situation_inventaire do
      libelle { 'Inventaire' }
      nom_technique { 'inventaire' }
    end

    factory :situation_controle do
      libelle { 'Contrôle' }
      nom_technique { 'controle' }
    end

    factory :situation_tri do
      libelle { 'Tri' }
      nom_technique { 'tri' }
    end

    factory :situation_securite do
      libelle { 'Sécurite' }
      nom_technique { 'securite' }
    end

    factory :situation_maintenance do
      libelle { 'Maintenance' }
      nom_technique { 'maintenance' }
    end

    factory :situation_livraison do
      libelle { 'Livraison' }
      nom_technique { 'livraison' }
    end

    factory :situation_objets_trouves do
      libelle { 'Objets Trouvés' }
      nom_technique { 'objets_trouves' }
    end

    factory :situation_bienvenue do
      libelle { 'Bienvenue' }
      nom_technique { 'bienvenue' }
    end
  end
end
