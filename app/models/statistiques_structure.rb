# frozen_string_literal: true

class StatistiquesStructure
  attr_reader :structure

  def initialize(structure)
    @structure = structure
  end

  # Nombre d'évaluations pour chaque structure enfants des 3 derniers mois
  #
  # @return [Hash] { ['Paris', 'octobre'] => 1 })
  def nombre_evaluations_des_3_derniers_mois
    evaluations = Evaluation.pour_les_structures(structures)
                            .des_3_derniers_mois
                            .group(groupe_par)
                            .group_by_month(:created_at, format: '%B')
                            .count
    if a_des_petits_enfants?
      evaluations = regroupe_nombre_evaluations_par_structures_enfants(evaluations)
    end
    evaluations
  end

  private

  def regroupe_nombre_evaluations_par_structures_enfants(evaluations)
    statistique = {}

    evaluations.each do |key, nombre_evaluations|
      structures_enfants_avec_dependance.find do |enfant, structures_dependantes|
        next if structure_trouvee(enfant, structures_dependantes, key).blank?

        key[0] = enfant&.nom
        statistique[key] ||= 0
        statistique[key] += nombre_evaluations
      end
    end
    statistique
  end

  def structure_trouvee(enfant, structures_dependantes, key)
    enfant.id == key[0] ? enfant : structures_dependantes.find { |s| s.id == key[0] }
  end

  def structures_enfants_avec_dependance
    @structures_enfants_avec_dependance ||= begin
      enfants = Structure.structures_enfants(@structure)
      resultat = {}
      enfants.each do |enfant|
        resultat[enfant] = enfant.structures_dependantes
      end
      resultat
    end
  end

  def structures
    structures_dependantes.presence || structure
  end

  def structures_dependantes
    @structures_dependantes ||= if structure.instance_of?(StructureAdministrative)
                                  structure.structures_dependantes
                                else
                                  []
                                end
  end

  def a_des_petits_enfants?
    @a_des_petits_enfants ||= structures_dependantes.any? do |s|
      s.structure_referente_id != structure.id
    end
  end

  def groupe_par
    a_des_petits_enfants? ? 'structures.structure_referente_id' : 'structures.nom'
  end
end
