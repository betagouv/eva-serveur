# frozen_string_literal: true

class DsfrBoutonComponent < ViewComponent::Base
  def initialize(label:, btn_level: :primary, btn_size: :md, icon: nil, html_attributes: {})
    @label = label
    @btn_level = btn_level
    @btn_size = btn_size
    @icon = icon
    @html_attributes = html_attributes
  end

  def btn_classes
    classes = [ "fr-btn" ]
    classes << "fr-btn--#{@btn_level}"
    classes << "fr-btn--icon-left" if @icon
    classes << "fr-icon-#{@icon}" if @icon
    classes << "fr-btn--sm" if @btn_size == :sm
    classes.join(" ")
  end

  def html_attributes
    @html_attributes.map { |key, value| "#{key}=\"#{value}\"" }.join(" ")
  end
end
