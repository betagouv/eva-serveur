class ToggleComponent < ViewComponent::Base
  def initialize(f:, method:, label:, classes: nil)
    @f = f
    @method = method
    @label = label
    @classes = classes
  end

  def input_id
    "#{@f.object_name}_#{@method}"
  end

  def input_html_options
    { class: "fr-toggle__input", aria: { describedby: "#{input_id}-messages" }, id: input_id }
  end
end
