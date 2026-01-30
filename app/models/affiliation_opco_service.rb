# frozen_string_literal: true

class AffiliationOpcoService
  def initialize(structure)
    @structure = structure
  end

  def opcos_possibles
    trouve_opcos_par_idcc
  end

  def affilie_opcos
    return if @structure.idcc.blank?

    opcos = opcos_possibles
    return if opcos.empty?
    return if @structure.opco_id.present?
    return unless opcos.size == 1

    @structure.opco_id = opcos.first.id
    @structure.save if @structure.persisted?
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

    str = idcc.to_s.strip
    # Pour la comparaison avec les IDCC des Opcos (stockés en 4 chiffres après import),
    # on padde les codes purement numériques à 4 chiffres (ex. "3" -> "0003", "843" -> "0843").
    str = str.rjust(4, "0") if str.match?(/\A\d+\z/)
    str
  end
end
