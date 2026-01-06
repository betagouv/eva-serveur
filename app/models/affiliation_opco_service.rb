class AffiliationOpcoService
  def initialize(structure)
    @structure = structure
  end

  def affilie_opcos
    return if @structure.idcc.blank?

    opcos_trouves = trouve_opcos_par_idcc
    return if opcos_trouves.empty?

    opcos_trouves.each do |opco|
      if @structure.persisted?
        @structure.structure_opcos.find_or_create_by(opco: opco)
      else
        # Pour les structures non persistées, on construit les associations
        # Elles seront sauvegardées quand la structure sera sauvegardée
        @structure.structure_opcos.build(opco: opco) unless opco_deja_associe?(opco)
      end
    end
  end

  def opco_deja_associe?(opco)
    @structure.structure_opcos.any? { |so| so.opco_id == opco.id }
  end

  private

  def trouve_opcos_par_idcc
    return [] if @structure.idcc.blank?

    idcc_normalises = @structure.idcc.map { |idcc| normalise_idcc(idcc) }.compact
    return [] if idcc_normalises.empty?

    # Trouver les Opcos dont l'array idcc contient au moins un des idcc de la structure
    # Utilise l'opérateur PostgreSQL && (overlaps) pour vérifier si les arrays
    # ont des éléments en commun. Il faut caster idcc en text[] pour la comparaison
    array_literal = "{#{idcc_normalises.map { |idcc| idcc.gsub(/[{}"]/, '') }.join(',')}}"
    Opco.where("idcc::text[] && ?::text[]", array_literal)
  end

  def normalise_idcc(idcc)
    return nil if idcc.blank?

    # Convertir en string et supprimer les espaces
    idcc.to_s.strip
  end
end
