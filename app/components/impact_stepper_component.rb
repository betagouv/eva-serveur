class ImpactStepperComponent < ViewComponent::Base
  NIVEAUX = [ :faible, :moyen, :fort, :tres_fort ].freeze

  def initialize(interpretation:, niveau:, icone: nil)
    @interpretation = interpretation
    @niveau = niveau
    @icone = icone
  end

  def titre_impact
    "Impact #{t("admin.evaluations.mesure_des_impacts.levels.#{@niveau}")}"
  end

  def label_interpretation
    t("admin.evaluations.mesure_des_impacts.labels.#{@interpretation}")
  end

  def description
    t("admin.evaluations.mesure_des_impacts.descriptions.#{@interpretation}.#{@niveau}")
  end

  def pourcentage_impact
    case @niveau
    when :faible then 25
    when :moyen then 50
    when :fort then 75
    when :tres_fort then 100
    else 0
    end
  end

  def nombre_reussies
    case @niveau
    when :faible then 1
    when :moyen then 2
    when :fort then 3
    when :tres_fort then 4
    else 0
    end
  end

  def nombre_total
    4
  end

  def nombre_non_passees
    nombre_total - nombre_reussies
  end

  def pourcentage_questions(nombre_questions)
    return 0 if nombre_total.zero?

    (nombre_questions.to_f / nombre_total) * 100
  end
end
