module Statistiques
  class Helper
    class << self
      def secondes_par_eval(condition)
        Evenement
          .joins(partie: :evaluation)
          .where(condition)
          .group("evaluations.id")
          .pluck(Arel.sql(sql_duree_evaluation))
      end

      private

      def sql_duree_evaluation
        "extract(epoch from (max(evenements.date) - evaluations.debutee_le)) as duree"
      end
    end
  end
end
