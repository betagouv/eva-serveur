# frozen_string_literal: true

class CardUsageComponent < ViewComponent::Base
  def initialize(titre:, description: nil, image: nil, submit_value: nil, aria_label: nil,
html_attributes: {})
    @titre = titre
    @description = description
    @image = image
    @submit_value = submit_value
    @aria_label = aria_label
    @html_attributes = html_attributes
  end

  def submit?
    @submit_value.present?
  end
end
