FactoryBot.define do
  factory :situation do
    libelle { 'Situation demo' }
    sequence(:nom_technique) { |n| "situation_demo__#{n}" }

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

    factory :situation_plan_de_la_ville do
      libelle { 'Plan de la ville' }
      nom_technique { 'plan_de_la_ville' }
    end

    factory :situation_cafe_de_la_place,
      aliases: [ :situation_litteratie ] do
      libelle { 'Café de la place' }
      nom_technique { 'cafe_de_la_place' }
    end

    factory :situation_place_du_marche,
        aliases: [ :situation_numeratie ] do
      libelle { 'Place du marché' }
      nom_technique { 'place_du_marche' }
    end
  end
end
