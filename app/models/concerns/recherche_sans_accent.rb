module RechercheSansAccent
  extend ActiveSupport::Concern

  class_methods do
    def ransack(params = {}, options = {})
      transformed_params = RansackParamsTransformer
        .new(ransack_unaccent_attributes()).converti(params)
      super(transformed_params, options)
    end

    def ransack_unaccent_attributes
      []
    end
  end

  class RansackParamsTransformer
    def initialize(attributs_a_transformer)
      @attributs_a_transformer = attributs_a_transformer
    end

    def converti(params)
      return transform_hash(params) if params.is_a?(Hash)
      return transform_hash(params.to_unsafe_h) if params.is_a?(ActionController::Parameters)

      params
    end

    private

    def transform_hash(hash)
      hash.transform_keys { |key| transform_key(key) }
          .transform_values { |value| transform_value(value) }
    end

    def transform_key(key)
      key_str = key.to_s
      return key_str.gsub(/_cont$/, "_contains_unaccent") if should_transform?(key_str)

      key
    end

    def should_transform?(key_str)
      @attributs_a_transformer.any? { |attr| key_str == "#{attr}_cont" }
    end

    def transform_value(value)
      case value
      when Hash then transform_hash(value)
      when Array then value.map { |v| v.is_a?(Hash) ? transform_hash(v) : v }
      else value
      end
    end
  end
end
