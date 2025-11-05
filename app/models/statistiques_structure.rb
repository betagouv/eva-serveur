class StatistiquesStructure
  attr_reader :structure

  def initialize(structure)
    @structure = structure
  end

  def url_structure_administrative
    payload = {
      resource: { dashboard: 53 },
      params: {
        "structures" => @structure.structures_locales_filles.pluck(:id)
      },
      exp: 10.minutes.from_now.to_i
    }
    token = ::JWT.encode payload, ENV.fetch("METABASE_SECRET_KEY", nil)

    "#{ENV.fetch('METABASE_SITE_URL', nil)}/embed/dashboard/#{token}#bordered=false&titled=false"
  end

  def url_structure_locale
    payload = {
      resource: { dashboard: 23 },
      params: {
        "id" => [ @structure.id ]
      },
      exp: 10.minutes.from_now.to_i
    }
    token = ::JWT.encode payload, ENV.fetch("METABASE_SECRET_KEY", nil)

    "#{ENV.fetch('METABASE_SITE_URL', nil)}/embed/dashboard/#{token}#bordered=false&titled=false"
  end

  # Nombre d'évaluations pour chaque structure enfants des 12 derniers mois
  # 12 derniers mois = 12 mois qui précèdent, sans le mois en cours
  #
  # @return [Hash] { ['Paris', 'octobre'] => 1 }
  def nombre_evaluations_des_12_derniers_mois
    evaluations = Evaluation.pour_les_structures(structures)
                            .des_12_derniers_mois
                            .group(groupe_par)
                            .group_by_month(:created_at, format: "%B %Y")
                            .count
    if a_des_petits_enfants?
      evaluations = regroupe_nombre_evaluations_par_structures_enfants(evaluations)
    end
    evaluations
  end

  # Répartition du nombre d'évaluations par niveau d'illettrime
  #
  # @return [Hash] { "illettrisme_potentiel" => 65, "ni_ni" => 45, "socle_clea" => 10 }
  def repartition_evaluations
    repartition = Evaluation.pour_les_structures(structures)
                            .des_12_derniers_mois
                            .where.not(synthese_competences_de_base: [ nil, :aberrant ])
                            .select(:synthese_competences_de_base)
                            .group(:synthese_competences_de_base)
                            .count
    repartition.transform_keys do |key|
      I18n.t("statistiques_structure.#{key}")
    end
  end

  # Pourcentage de données sociodémographiques par genre pour un niveau donné
  #
  # @return [Hash] { "homme" => 45, "femme" => 45, "autre" => 10 }
  def correlation_entre_niveau_illettrisme_et_genre(niveau)
    evaluations_par_genre = evaluations_par_genre(niveau)
    return if evaluations_par_genre.empty?

    evaluations_par_genre = transforme_valeurs_en_pourcentage(evaluations_par_genre)
    DonneeSociodemographique::GENRES.each { |genre| evaluations_par_genre[genre] ||= 0 }
    evaluations_par_genre
  end

  private

  def evaluations_par_genre(niveau)
    DonneeSociodemographique.where(
      evaluation_id: Evaluation.pour_les_structures(structures)
                .where(synthese_competences_de_base: niveau).select(:id)
    )
                            .group(:genre)
                            .count
  end

  def transforme_valeurs_en_pourcentage(hash)
    total_valeurs = hash.values.sum
    hash.update(hash) do |_cle, valeur|
      Pourcentage.new(valeur: valeur, valeur_max: total_valeurs).calcul
    end
  end

  def regroupe_nombre_evaluations_par_structures_enfants(evaluations)
    statistique = {}

    evaluations.each do |key, nombre_evaluations|
      structures_enfants_avec_dependance.find do |enfant, _value|
        key[0] = enfant&.nom
        statistique[key] ||= 0
        statistique[key] += nombre_evaluations
      end
    end
    statistique
  end

  def structures_enfants_avec_dependance
    @structures_enfants_avec_dependance ||= begin
      enfants = @structure.children
      resultat = {}
      enfants.each do |enfant|
        resultat[enfant] = enfant.children
      end
      resultat
    end
  end

  def structures
    structures_dependantes.presence || structure
  end

  def structures_dependantes
    @structures_dependantes ||= if structure.instance_of?(StructureAdministrative)
                                  structure.descendants
    else
                                  []
    end
  end

  def a_des_petits_enfants?
    @a_des_petits_enfants ||= structures_dependantes.any? do |s|
      s.parent_id != structure.id
    end
  end

  def groupe_par
    a_des_petits_enfants? ? "structures.ancestry" : "structures.nom"
  end
end
