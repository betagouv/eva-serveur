class BoutonComponent < ViewComponent::Base
  attr_accessor :type

  PRIMARY_CLASSES = %w[
    bouton
  ].freeze
  SECONDARY_CLASSES = %w[
    bouton-secondaire
  ].freeze
  DESACTIVE_CLASSES = %w[
    bouton
    bouton--desactive
  ].freeze

  BUTTON_TYPE_MAPPINGS = {
    primary: PRIMARY_CLASSES,
    secondary: SECONDARY_CLASSES,
    desactive: DESACTIVE_CLASSES
  }.freeze

  BUTTON_SIZE_MAPPINGS = {
    xs: "tres-petit-bouton",
    sm: "petit-bouton",
    md: "grand-bouton"
  }.freeze

  def initialize(url, type: :primary, tag: :a, size: :md, **params)
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
