Ransack.configure do |config|
  config.add_predicate "contains_unaccent",
                       arel_predicate: "matches",
                       formatter: proc { |v| "%#{v}%" },
                       validator: proc { |v| v.present? },
                       type: :string,
                       compounds: false,
                       wants_array: false
end

# Monkey patch pour appliquer unaccent dans les prédicats matches
module Ransack
  module Nodes
    class Condition
      alias_method :original_arel_predicate, :arel_predicate

      def arel_predicate(*args)
        if predicate.name == "contains_unaccent"
          # Récupère la valeur formatée (avec les % ajoutés par le formatter)
          formatted_value = predicate.format(value)

          ransack_attribute = attributes.first
          arel_table = context.klassify(ransack_attribute.parent).arel_table
          arel_attribute = arel_table[ransack_attribute.name]

          unaccent_column = Arel::Nodes::NamedFunction.new("unaccent", [arel_attribute])
          replace_column = Arel::Nodes::NamedFunction.new("REPLACE",
            [unaccent_column, Arel::Nodes.build_quoted("-"), Arel::Nodes.build_quoted(" ")])

          unaccent_value = Arel::Nodes::NamedFunction.new("unaccent", [Arel::Nodes.build_quoted(formatted_value)])
          replace_value = Arel::Nodes::NamedFunction.new("REPLACE",
            [unaccent_value, Arel::Nodes.build_quoted("-"), Arel::Nodes.build_quoted(" ")])

          return replace_column.matches(replace_value)
        end

        original_arel_predicate(*args)
      end
    end
  end
end
