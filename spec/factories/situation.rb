# frozen_string_literal: true

FactoryBot.define do
  factory :situation do
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
  end
end
