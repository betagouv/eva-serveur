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
    as: nil,
    collection: nil,
    include_blank: nil,
    **html_options
  )
    assign_basic_attributes(id, label, hint, value, type, placeholder, required, pattern,
autocomplete)
    assign_form_attributes(form, method, name)
    assign_button_attributes(button_text, button_type, button_action)
    assign_link_attributes(link_text, link_url, link_html)
    assign_select_attributes(as, collection, include_blank)
    @input_html = input_html
    @html_options = html_options
  end

  private

  def assign_basic_attributes(id, label, hint, value, type, placeholder, required, pattern,
autocomplete)
    @id = id
    @label = label
    @hint = hint
    @value = value
    @type = type
    @placeholder = placeholder
    @required = required
    @pattern = pattern
    @autocomplete = autocomplete
  end

  def assign_form_attributes(form, method, name)
    @form = form
    @method = method
    @name = name || compute_default_name
  end

  def assign_button_attributes(button_text, button_type, button_action)
    @button_text = button_text
    @button_type = button_type
    @button_action = button_action
  end

  def assign_link_attributes(link_text, link_url, link_html)
    @link_text = link_text
    @link_url = link_url
    @link_html = link_html
  end

  def assign_select_attributes(as, collection, include_blank)
    @as = as
    @collection = collection
    @include_blank = include_blank
  end

  def compute_default_name
    return nil if @form.present? && @method.present?

    @id
  end

  public

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
    classes = [ "fr-input-wrap" ]
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
    classes = [ "fr-btn" ]
    classes << "bouton-action" if has_action_button?
    classes.join(" ")
  end

  def has_link?
    @link_text.present? && @link_url.present?
  end

  def has_errors?
    return false unless use_form_builder?
    return false unless @form.object.respond_to?(:errors)

    @form.object.errors[@method].present?
  end

  def errors
    return [] unless has_errors?
    @form.object.errors[@method]
  end

  def error_html
    return "" unless has_errors?
    errors.map { |error|
      "<p class=\"fr-message fr-message--error\">#{error}</p>"
    }.join.html_safe
  end

  def input_group_classes
    if is_select?
      classes = [ "fr-select-group" ]
      classes << "fr-select-group--error" if has_errors?
    else
      classes = [ "fr-input-group" ]
      classes << "fr-input-group--error" if has_errors?
    end
    classes.join(" ")
  end

  def is_required?
    return @required if @required == true || @required == false
    return false unless use_form_builder?

    # Vérifier si Formtastic considère le champ comme requis
    return false unless @form.respond_to?(:required?)

    @form.required?(@method)
  end

  def required_asterisk
    return "" unless is_required?

    safe_join([ " ", tag.abbr("*", title: "required") ])
  end

  def is_select?
    @as == :select || @collection.present?
  end

  def select_attributes
    attrs = {
      class: "fr-select",
      id: input_id,
      "aria-describedby" => messages_id
    }
    attrs[:name] = @name if @name.present?
    attrs[:required] = true if @required
    attrs.merge!(@input_html)
    attrs
  end

  def render_select_field
    if use_form_builder?
      render_select_with_form_builder
    else
      render_select_without_form_builder
    end
  end

  private

  def render_select_with_form_builder
    @form.select(@method, @collection, { include_blank: @include_blank, selected: @value },
select_attributes)
  end

  def render_select_without_form_builder
    options = build_select_options
    tag.select(safe_join(options), **select_attributes)
  end

  def build_select_options
    options = []
    options << build_blank_option if @include_blank.present?
    options.concat(build_collection_options)
    options
  end

  def build_blank_option
    tag.option(@include_blank, value: "", selected: @value.blank?, disabled: true, hidden: true)
  end

  def build_collection_options
    return [] unless @collection.present?

    @collection.map do |option|
      text, value = extract_option_text_and_value(option)
      selected = option_selected?(value)
      tag.option(text, value: value, selected: selected)
    end
  end

  def extract_option_text_and_value(option)
    option.is_a?(Array) ? option : [ option, option ]
  end

  def option_selected?(value)
    @value.present? && (@value.to_s == value.to_s)
  end

  public
end
