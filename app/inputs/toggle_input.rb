class ToggleInput < Formtastic::Inputs::BooleanInput
  def to_html
    input_wrapping do
      template.render(ToggleComponent.new(
        f: builder,
        method: method,
        label: label_text
      ))
    end
  end
end
