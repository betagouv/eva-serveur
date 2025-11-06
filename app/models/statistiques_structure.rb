class StatistiquesStructure
  attr_reader :structure

  def initialize(structure)
    @structure = structure
  end

  def url
    payload = {
      resource: { dashboard: @structure.metabase_dashboard },
      params: @structure.metabase_query_params,
      exp: 10.minutes.from_now.to_i
    }
    token = ::JWT.encode payload, ENV.fetch("METABASE_SECRET_KEY", nil)

    "#{ENV.fetch('METABASE_SITE_URL', nil)}/embed/dashboard/#{token}#bordered=false&titled=false"
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
end
