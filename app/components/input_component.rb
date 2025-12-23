# frozen_string_literal: true

class InputComponent < ViewComponent::Base
  def initialize(
    id:,
    label:,
    hint: nil,
    name: nil,
    value: nil,
    type: "text",
    placeholder: nil,
    required: false,
    pattern: nil,
    autocomplete: nil,
    button_text: nil,
    button_type: nil,
    button_action: nil,
    link_text: nil,
    link_url: nil,
    link_html: {},
    form: nil,
    method: nil,
    input_html: {},
    **html_options
  )
    @id = id
    @label = label
    @hint = hint
    @form = form
    @method = method
    @name = name || (form && method ? nil : id)
    @value = value
    @type = type
    @placeholder = placeholder
    @required = required
    @pattern = pattern
    @autocomplete = autocomplete
    @button_text = button_text
    @button_type = button_type # :button ou :action
    @button_action = button_action
    @link_text = link_text
    @link_url = link_url
    @link_html = link_html
    @input_html = input_html
    @html_options = html_options
  end

  def input_id
    if use_form_builder?
      @form.object_name.present? ? "#{@form.object_name}_#{@method}" : @method.to_s
    else
      @id
    end
  end

  def messages_id
    "#{@id}-messages"
  end

  def has_button?
    @button_text.present?
  end

  def has_addon?
    has_button? && @button_type != :action
  end

  def has_action_button?
    has_button? && @button_type == :action
  end

  def input_wrap_classes
    classes = ["fr-input-wrap"]
    classes << "fr-input-wrap--addon" if has_addon?
    classes.join(" ")
  end

  def input_attributes
    attrs = {
      class: "fr-input",
      id: input_id,
      type: @type,
      "aria-describedby" => messages_id
    }
    attrs[:name] = @name if @name.present?
    attrs[:value] = @value if @value.present?
    attrs[:placeholder] = @placeholder if @placeholder.present?
    attrs[:required] = true if @required
    attrs[:pattern] = @pattern if @pattern.present?
    attrs[:autocomplete] = @autocomplete if @autocomplete.present?
    attrs.merge!(@input_html)
    attrs
  end

  def use_form_builder?
    @form.present? && @method.present?
  end

  def form_builder_method
    case @type
    when "email"
      :email_field
    when "password"
      :password_field
    when "number"
      :number_field
    when "tel"
      :telephone_field
    when "url"
      :url_field
    when "search"
      :search_field
    else
      :text_field
    end
  end

  def button_classes
    classes = ["fr-btn"]
    classes << "bouton-action" if has_action_button?
    classes.join(" ")
  end

  def has_link?
    @link_text.present? && @link_url.present?
  end
end

