module Arel
  module Nodes
    StddevPop = Class.new(Function)
  end

  module Expressions
    def stddev_pop
      Nodes::StddevPop.new [self]
    end
  end

  module Visitors
    class ToSql
      private

      def visit_Arel_Nodes_StddevPop(o, collector)
        aggregate 'STDDEV_POP', o, collector
      end
    end
  end
end
