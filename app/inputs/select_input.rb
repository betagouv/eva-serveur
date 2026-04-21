# frozen_string_literal: true

class SelectInput < Formtastic::Inputs::SelectInput
  def initialize(builder, template, object, object_name, method, options)
    super
    evalue_collection_callable
    applique_placeholder_select2
  end

  private

  def evalue_collection_callable
    collection = @options[:collection]
    return unless collection.respond_to?(:call)

    @options[:collection] = template.instance_exec(&collection)
  end

  def applique_placeholder_select2
    placeholder = placeholder_text
    return if placeholder.blank?

    renseigne_donnees_select2(placeholder)
    force_include_blank_texte(placeholder)
  end

  def renseigne_donnees_select2(placeholder)
    data = input_data_options
    data[:placeholder] ||= placeholder
    data[:allow_clear] = true if data[:allow_clear].nil?
  end

  def force_include_blank_texte(placeholder)
    @options[:include_blank] = placeholder if @options[:include_blank] == true
  end

  def input_data_options
    @options[:input_html] ||= {}
    @options[:input_html][:data] ||= {}
  end

  def placeholder_text
    @options[:placeholder] || include_blank_text
  end

  def include_blank_text
    return nil unless @options[:include_blank].is_a?(String)

    @options[:include_blank]
  end
end
