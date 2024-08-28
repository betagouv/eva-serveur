# frozen_string_literal: true

class BoutonComponent < ViewComponent::Base
  attr_accessor :type

  PRIMARY_CLASSES = %w[
    bouton-arrondi
  ].freeze
  SECONDARY_CLASSES = %w[
    bouton-arrondi
    text-primary
    border-primary
    bg-white
  ].freeze
  DESACTIVE_CLASSES = %w[
    bouton-arrondi
    bouton--desactive
  ].freeze
  BASE_CLASSES = %w[
    bouton
  ].freeze

  BUTTON_TYPE_MAPPINGS = {
    primary: PRIMARY_CLASSES,
    secondary: SECONDARY_CLASSES,
    desactive: DESACTIVE_CLASSES
  }.freeze

  def initialize(body, url, type: nil, **params)
    @body = body
    @url = url
    @type = type
    @params = params
    @params[:class] ||= ''
    @params[:class] += " #{classes}"
  end

  def classes
    classes = BASE_CLASSES
    classes += BUTTON_TYPE_MAPPINGS[@type] if @type.present?
    classes = classes.flatten
    classes.join(' ')
  end
end
