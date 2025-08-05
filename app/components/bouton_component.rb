# frozen_string_literal: true

class BoutonComponent < ViewComponent::Base
  attr_accessor :type

  PRIMARY_CLASSES = %w[
    bouton
    grand-bouton
  ].freeze
  SECONDARY_CLASSES = %w[
    bouton-secondaire
    grand-bouton
  ].freeze
  DESACTIVE_CLASSES = %w[
    bouton
    grand-bouton
    bouton--desactive
  ].freeze

  BUTTON_TYPE_MAPPINGS = {
    primary: PRIMARY_CLASSES,
    secondary: SECONDARY_CLASSES,
    desactive: DESACTIVE_CLASSES
  }.freeze

  def initialize(url, type: :primary, **params)
    @url = url
    @type = type
    @params = params
    @params[:class] ||= ""
    @params[:class] += " #{classes}"
  end

  def classes
    BUTTON_TYPE_MAPPINGS[@type].join(" ")
  end
end
