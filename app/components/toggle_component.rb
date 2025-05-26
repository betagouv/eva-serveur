# frozen_string_literal: true

class ToggleComponent < ViewComponent::Base
  def initialize(f:, method:, label:)
    @f = f
    @method = method
    @label = label
  end

  def input_id
    "#{@f.object_name}_#{@method}"
  end

  def input_html_options
    { class: "fr-toggle__input", aria: { describedby: "#{input_id}-messages" }, id: input_id }
  end
end