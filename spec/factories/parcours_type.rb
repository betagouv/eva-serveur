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

    trait :avec_situations_configurations do
      situations_configurations do
        situation = create(:situation_maintenance)
        build_list(:situation_configuration, 1, situation: situation)
      end
    end

    trait :diagnostic do
      type_de_programme { :diagnostic }
    end

    trait :positionnement do
      type_de_programme { :positionnement }
    end

    trait :evapro do
      type_de_programme { :diagnostic_entreprise }
    end
  end
end
