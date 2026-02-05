class BoutonComponent < ViewComponent::Base
  attr_accessor :type

  PRIMARY_CLASSES = %w[
    bouton
  ].freeze
  SECONDARY_CLASSES = %w[
    bouton-secondaire
  ].freeze
  TERTIARY_CLASSES = %w[
    bouton-tertiaire
  ].freeze
  DESACTIVE_CLASSES = %w[
    bouton
    bouton--desactive
  ].freeze

  BUTTON_TYPE_MAPPINGS = {
    primary: PRIMARY_CLASSES,
    secondary: SECONDARY_CLASSES,
    tertiary: TERTIARY_CLASSES,
    desactive: DESACTIVE_CLASSES
  }.freeze

  BUTTON_SIZE_MAPPINGS = {
    xs: "tres-petit-bouton",
    sm: "petit-bouton",
    md: "grand-bouton"
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
    @params[:class] += " #{classes} #{BUTTON_SIZE_MAPPINGS[@size]}"
  end

  def classes
    BUTTON_TYPE_MAPPINGS[@type].join(" ")
  end
end
