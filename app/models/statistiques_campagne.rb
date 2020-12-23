# frozen_string_literal: true

class StatistiquesCampagne
  attr_reader :temps_min, :temps_max, :temps_moyen

  def initialize(campagne)
    @campagne = campagne
    calcule!
  end

  def calcule!
    return if secondes_par_eval.empty?

    @temps_min = secondes_par_eval.min
    @temps_max = secondes_par_eval.max
    @temps_moyen = DescriptiveStatistics.mean(secondes_par_eval)
  end

  def secondes_par_eval
    @secondes_par_eval ||=
      Evenement
      .joins(partie: :evaluation)
      .where('evaluations.campagne_id': @campagne.id)
      .group('evaluations.id')
      .pluck(Arel.sql('extract(epoch from (max(date) - evaluations.created_at)) as duree'))
  end

  def to_h
    {
      temps_min: @temps_min,
      temps_max: @temps_max,
      temps_moyen: @temps_moyen
    }
  end
end
