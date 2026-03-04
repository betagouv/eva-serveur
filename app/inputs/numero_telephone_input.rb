# frozen_string_literal: true

class NumeroTelephoneInput < Formtastic::Inputs::StringInput
  def initialize(builder, template, object, object_name, method, options)
    super
    @options[:hint] ||= I18n.t("formtastic.inputs.numero_telephone.hint")
  end

  def to_html
    input_wrapping do
      label_html <<
        numero_telephone_input_html <<
        error_html
    end
  end

  private

  def numero_telephone_input_html
    builder.telephone_field(method, input_html_options_avec_contraintes)
  end

  def input_html_options_avec_contraintes
    input_html_options.dup.tap do |html|
      html.merge!(numero_telephone_attributs_html)
      valeur = FormatageNumeroTelephone.formater(valeur_brute)
      html[:value] = valeur if valeur.present?
    end
  end

  def numero_telephone_attributs_html
    {
      "data-numero-telephone-input" => "true",
      inputmode: "tel",
      autocomplete: "tel",
      placeholder: "(+33) 1 22 33 44 55"
    }
  end

  def valeur_brute
    return nil unless object.respond_to?(method)

    object.public_send(method)
  end
end
