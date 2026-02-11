class BoutonDsfrComponent < ViewComponent::Base
  attr_accessor :type

  PRIMARY_CLASSES = %w[
    fr-btn
  ].freeze
  SECONDARY_CLASSES = %w[
    fr-btn
    fr-btn--secondary
  ].freeze
  TERTIARY_CLASSES = %w[
    fr-btn
    fr-btn--tertiary
  ].freeze
  DESACTIVE_CLASSES = %w[
    fr-btn
    fr-btn--disabled
  ].freeze

  BUTTON_TYPE_MAPPINGS = {
    primary: PRIMARY_CLASSES,
    secondary: SECONDARY_CLASSES,
    tertiary: TERTIARY_CLASSES,
    desactive: DESACTIVE_CLASSES
  }.freeze

  BUTTON_SIZE_MAPPINGS = {
    xs: "fr-btn--sm",
    sm: "fr-btn--sm",
    md: nil
  }.freeze

  BUTTON_TAG_MAPPINGS = %i[a submit button button_with_form].freeze

  def initialize(url, type: :primary, tag: :a, size: :md, **params)
    unless BUTTON_TAG_MAPPINGS.include?(tag)
      raise "Tag must be one of #{BUTTON_TAG_MAPPINGS.join(", ")}"
    end

    @url = url
    @type = type
    @tag = tag
    @size = size
    @params = params
    @params[:class] ||= ""
    @params[:class] += " #{classes}"
    @params[:class] += " #{BUTTON_SIZE_MAPPINGS[@size]}" if BUTTON_SIZE_MAPPINGS[@size].present?
  end

  def classes
    BUTTON_TYPE_MAPPINGS[@type].join(" ")
  end
end
