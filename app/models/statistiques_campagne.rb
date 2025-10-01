class StatistiquesCampagne
  attr_reader :temps_min, :temps_max, :temps_moyen

  def initialize(campagne)
    @campagne = campagne
    calcule!
  end

  def calcule!
    durees = Statistiques::Helper.secondes_par_eval('evaluations.campagne_id': @campagne.id)
    return if durees.empty?

    @temps_min = durees.min
    @temps_max = durees.max
    @temps_moyen = DescriptiveStatistics.mean(durees)
  end

  def to_h
    {
      temps_min: @temps_min,
      temps_max: @temps_max,
      temps_moyen: @temps_moyen
    }
  end
end
