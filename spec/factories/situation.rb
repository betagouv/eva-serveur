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
  end
end
