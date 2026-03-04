# frozen_string_literal: true

class EmailInput < Formtastic::Inputs::StringInput
  def initialize(builder, template, object, object_name, method, options)
    super
    @options[:hint] ||= I18n.t("formtastic.inputs.email.hint")
  end

  def to_html
    input_wrapping do
      label_html <<
        email_input_html <<
        error_html
    end
  end

  private

  def email_input_html
    builder.email_field(method, input_html_options_avec_contraintes)
  end

  def input_html_options_avec_contraintes
    input_html_options.dup.tap do |html|
      html.merge!(
        autocomplete: "email",
        placeholder: "nom@domaine.fr"
      )
    end
  end
end
