# frozen_string_literal: true

FactoryBot.define do
  factory :parcours_type do
    sequence(:libelle) { |n| "Parcours type ##{n}" }
    sequence(:nom_technique) { |n| "parcours_type_#{n}" }
    duree_moyenne { '1 heure' }
    type_de_programme { :diagnostic }

    trait :complet do
      libelle { 'Parcours complet' }
      nom_technique { 'complet' }
      type_de_programme { :diagnostic }
    end

    trait :evacob do
      libelle { 'Evacob' }
      nom_technique { 'evacob' }
      type_de_programme { :positionnement }

      before(:create) do |parcours_type|
        situation = create(:situation_cafe_de_la_place)
        parcours_type.situations_configurations_attributes = [ { situation: situation } ]
      end
    end

    trait :competences_de_base do
      libelle { 'Parcours compétences de base' }
      nom_technique { 'competences_de_base' }
      type_de_programme { :diagnostic }

      before(:create) do |parcours_type|
        maintenance = create(:situation_maintenance)
        livraison = create(:situation_livraison)
        objets_trouves = create(:situation_objets_trouves)
        parcours_type.situations_configurations_attributes = [
          { situation: maintenance },
          { situation: livraison },
          { situation: objets_trouves }
        ]
      end
    end
  end
end
